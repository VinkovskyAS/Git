#Использовать "lib/gitrunner"
#Использовать v8runner
#Использовать 1commands
#Использовать json
#Использовать strings


Перем ИмяРепозитория; // Имя Удаленного репозитория, заполняется из файла настроек repositoryName
Перем ЛокальныйКаталогРепозитория; // Путь к локальному репозиторию, заполняется из файла настроек reositoryLocalName
Перем СтруктураПараметровБазы; // Структура параметров подключения к конфигурации 1с, заполняется из файла настроек base
Перем СтруктураПараметровЕДТ; // Структура параметров подключения к EDT, заполняется из файла настроек edt;
Перем ФайлИсторииКоммитов; // Путь к файлу истории коммитор, заполняется из файла настроек edt.fileCommitHistory
Перем СтруктураПараметровТелеграм; // Структура параметров телеграм, заполняется из файла настроек telegram
Перем ГитРепозиторий; // Инициализированный объект Git репозитория
Перем СтруктураПараметроТрекер; // Структура параметров подключния к youtrack, заполняется из файла настроек youtrack

Процедура УстановитьВерсиюПлатформы(Конфигуратор)
	Если ЗначениеЗаполнено(СтруктураПараметровБазы.v8Version) Тогда
		Конфигуратор.ИспользоватьВерсиюПлатформы(СтруктураПараметровБазы.v8Version);
	КонецЕсли;
КонецПроцедуры

Процедура ОпределитьНастройки()
	ЧтениеJson = Новый ЧтениеJson;
	ЧтениеJson.ОткрытьФайл("config.json");
	НастройкиИзJson = ПрочитатьJSON(ЧтениеJson);
	ЧтениеJson.Закрыть();
	ИмяРепозитория = НастройкиИзJson.repositoryName;
	ЛокальныйКаталогРепозитория = НастройкиИзJson.reositoryLocalName;
	ЛокальныйКаталогРепозитория = СтрЗаменить(ЛокальныйКаталогРепозитория, "/", "\");
	СтруктураПараметровБазы = НастройкиИзJson.base;
	СтруктураПараметровЕДТ = НастройкиИзJson.edt;
	ФайлИсторииКоммитов = СтрЗаменить(СтруктураПараметровЕДТ.fileCommitHistory, "/", "\");
	СтруктураПараметровТелеграм = НастройкиИзJson.telegram;
	СтруктураПараметроТрекер = НастройкиИзJson.youtrack;
КонецПроцедуры



Процедура ПолучитьИзУдаленногоРепозитория()
	НоваяВетка = СтруктураПараметровЕДТ.brancheName + "_" + Формат(ТекущаяДата(), "ДФ=гггг_ММ_дд_ЧЧ_мм");
	ГитРепозиторий = Новый ГитРепозиторий();
	ГитРепозиторий.УстановитьРабочийКаталог(ЛокальныйКаталогРепозитория);
	ГитРепозиторий.Получить(ИмяРепозитория, СтруктураПараметровЕДТ.brancheName);
	Сообщить("Получили ветку " + СтруктураПараметровЕДТ.brancheName + " из удаленного репозитория");
	ГитРепозиторий.СоздатьВетку(НоваяВетка);
	Сообщить("Создали ветку " + НоваяВетка + " в локальном репозитории");

	ГитРепозиторий.ПерейтиВВетку(НоваяВетка);

КонецПроцедуры

Процедура ПолучитьИсторию()
	СекундВЧасе = 3600;
	НачачалоПериодаКоммитов = ТекущаяДата() - (СтруктураПараметровЕДТ.periodCommins * СекундВЧасе);
	НачачалоПериодаКоммитовСтрокой = Формат(НачачалоПериодаКоммитов, "гггг-ММ-ддTЧЧ:мм:сс-00:00");
	ДатаНачалаКоммитов = "--since=" + Символ(34) + НачачалоПериодаКоммитовСтрокой + Символ(34);
	
	КомандаПолученияИстории = "--no-pager log ДатаНачалаКоммитов >  ФайлИсторииКоммитов";
	КомандаПолученияИстории = СтрЗаменить(КомандаПолученияИстории, "ФайлИсторииКоммитов", ФайлИсторииКоммитов);
	КомандаПолученияИстории = СтрЗаменить(КомандаПолученияИстории, "ДатаНачалаКоммитов", ДатаНачалаКоммитов);

	ГитРепозиторий.ВывестиИсторию(Ложь, КомандаПолученияИстории);
КонецПроцедуры

Процедура ЗагрузитьКонфигурациюИзФайлов()
	КаталогВыгрузки = СтрЗаменить(СтруктураПараметровЕДТ.configurationFiles, "/", "\");
	Конфигуратор = Новый УправлениеКонфигуратором();
	УстановитьКонтекст(Конфигуратор);
	Конфигуратор.ЗагрузитьКонфигурациюИзФайлов(КаталогВыгрузки);
	УдалитьФайлы(КаталогВыгрузки);

	Сообщить("Загрузили файлы кофигурации");
	Конфигуратор.ОбновитьКонфигурациюБазыДанных(Ложь, Истина);
	Сообщить("Обновили конфигурацию базы данных");
КонецПроцедуры

Процедура УстановитьКонтекст(Конфигуратор)
	ПараметрыСтрокиСоединения = Конфигуратор.ПараметрыСтрокиСоединения();

	Если СтруктураПараметровБазы.isFileBase = true  Тогда
		ИмяБазы = СтрЗаменить(СтруктураПараметровБазы.name, "/", "\");
		ПараметрыСтрокиСоединения.ПутьКФайлуБазы = ИмяБазы;
	Иначе
		ПараметрыСтрокиСоединения.Сервер = СтруктураПараметровБазы.Srvr;
		ПараметрыСтрокиСоединения.ИмяБазы = СтруктураПараметровБазы.name;
		ПараметрыСтрокиСоединения.Порт = СтруктураПараметровБазы.potr;
	КонецЕсли;

	Конфигуратор.УстановитьКонтекст(ПараметрыСтрокиСоединения, 
										СтруктураПараметровБазы.login, 
										СтруктураПараметровБазы.pass);
	УстановитьВерсиюПлатформы(Конфигуратор);

КонецПроцедуры

Процедура ВыгрузитьВФайлыИзЕДТ()
	КаталогВыгрузки = СтрЗаменить(СтруктураПараметровЕДТ.configurationFiles, "/", "\");
	РабочаяОбласть = СтрЗаменить(СтруктураПараметровЕДТ.workspaceLocation, "/", "\");
	КаталогЕдт = СтрЗаменить(СтруктураПараметровЕДТ.edtLocation, "/", "\");
	ПроектаЕдт = СтрЗаменить(СтруктураПараметровЕДТ.project, "/", "\");
	УдалитьФайлы(КаталогВыгрузки);
	ТекстКоманднойСтроки = "ring ВерсияЕдт workspace export --project ПроектаЕдт 
	|--configuration-files КаталогВыгрузки --workspace-location РабочаяОбласть";
	ТекстКоманднойСтроки = СтрЗаменить(ТекстКоманднойСтроки, "ВерсияЕдт", СтруктураПараметровЕДТ.edtVersion);
	ТекстКоманднойСтроки = СтрЗаменить(ТекстКоманднойСтроки, "ПроектаЕдт", ПроектаЕдт);
	ТекстКоманднойСтроки = СтрЗаменить(ТекстКоманднойСтроки, "КаталогВыгрузки", КаталогВыгрузки);
	ТекстКоманднойСтроки = СтрЗаменить(ТекстКоманднойСтроки, "РабочаяОбласть", РабочаяОбласть);
	ТекстКоманднойСтроки = СтрЗаменить(ТекстКоманднойСтроки, "КаталогЕдт", КаталогЕдт);
	Команда = Новый Команда;
	Команда.УстановитьСтрокуЗапуска(ТекстКоманднойСтроки);

	КодВозврата = Команда.Исполнить();
	

	 Сообщить("Выгрузили файлы кофигурации");


КонецПроцедуры

Процедура ОтрпавитьИсториюКоммитов()

	МассивКоммитов = Новый Массив();

	ТекстДок = Новый ЧтениеТекста(ФайлИсторииКоммитов,"UTF-8");
	СтрокаИстории = ТекстДок.ПрочитатьСтроку();
	СтруктураКоммита = Неопределено;
	ЭтоКоммит = Ложь;
	Пока СтрокаИстории <> Неопределено Цикл 
		СтрокаИстории = СокрЛП(СтрокаИстории);
		Если СтрокаИстории = "" Тогда
			СтрокаИстории = ТекстДок.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;	
		Если СтрНачинаетсяС(СтрокаИстории,"commit") Тогда
			Если Не СтруктураКоммита = Неопределено Тогда
				МассивКоммитов.Добавить(СтруктураКоммита);
			КонецЕсли;
			СтруктураКоммита = Новый Структура("Автор, Коммит","","");
			ЭтоКоммит = Истина;
			СтрокаИстории = ТекстДок.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(СтрокаИстории,"Merge: ") Тогда
			ЭтоКоммит = Ложь;
			СтрокаИстории = ТекстДок.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(СтрокаИстории, "Author") И ЭтоКоммит Тогда
			СтруктураКоммита.Автор = СтрЗаменить(СтрокаИстории, "Author", "Автор");	
			СтрокаИстории = ТекстДок.ПрочитатьСтроку();
			Продолжить;
		КонецЕсли;
		Если СтрНачинаетсяС(СтрокаИстории, "Date") Тогда
			СтрокаИстории = ТекстДок.ПрочитатьСтроку();
			Продолжить;	
		КонецЕсли;
		Если ЭтоКоммит Тогда
			СтруктураКоммита.Коммит = СтруктураКоммита.Коммит+СтрокаИстории;
		КонецЕсли;
		СтрокаИстории = ТекстДок.ПрочитатьСтроку();
	КонецЦикла;
	ПервоеСообщение = "Обновлена конфигурация: "+СтруктураПараметровБазы.name;
	ПервоеСообщение = ПервоеСообщение + Символы.ПС + "Задачи попавшие в обновление:";
	ОтправитьВТелеграм(ПервоеСообщение);
	Для Каждого Коммит ИЗ МассивКоммитов Цикл
		АвторПолный = СокрЛП(Коммит.Автор);
		МассивСтрокАвтора = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(АвторПолный, " ");
		Если МассивСтрокАвтора.Количество() >= 2 Тогда
			Автор = СокрЛП(МассивСтрокАвтора[0]) + " " + СокрЛП(МассивСтрокАвтора[1]);
		Иначе
			Автор = АвторПолный;
		КонецЕсли;
		
		ТекстИстории = Автор + Символы.ПС + СокрЛП(Коммит.Коммит);
		
		 ОтправитьВТелеграм(ТекстИстории);
	КонецЦИкла;
	
КонецПроцедуры

Процедура ОтправитьВТелеграм(ТекстИстории)
	json = Новый ПарсерJson;
	
	МассивПолучателей = СтруктураПараметровТелеграм.Recipients;
	
	
	СтруктураПараметров = Новый Структура("recipients, message", МассивПолучателей, ТекстИстории);

	СтрокаТелаJSON = json.ЗаписатьJSON(СтруктураПараметров);
	

	
	СоединениеСWH = Новый HTTPСоединение(СтруктураПараметровТелеграм.server, 443, , , , 100);
	ТекстСообщения = "";
	Попытка

		ЗапросХТТП = Новый HTTPЗапрос(СтруктураПараметровТелеграм.webhook);

		ЗапросХТТП.Заголовки.Вставить("token", СтруктураПараметровТелеграм.token);
		ЗапросХТТП.Заголовки.Вставить("Content-Type", "application/json");
		ЗапросХТТП.УстановитьТелоИзСтроки(СтрокаТелаJSON, КодировкаТекста.UTF8);
		
		РезультатЗапроса = СоединениеСWH.ОтправитьДляОбработки(ЗапросХТТП);

	Исключение

		ТекстСообщения = ОписаниеОшибки();

	КонецПопытки;

	Если ЗначениеЗаполнено(ТекстСообщения) Тогда
		Сообщить(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗадачиТрекера()

	Сервер = СтруктураПараметроТрекер.server;
	Токен  = "Bearer " + СтруктураПараметроТрекер.token;

	Соединение = Новый HTTPСоединение(Сервер, , , , , 100);
	ТекстСообщения = "";
	ТекстЗапросПроекты = "api/admin/projects?fields=id,name,shortName";
	ТекстЗапросаЗадачи = "api/issues?fields=$type,id,summary,customFields($type,id,projectCustomField($type,id,field($type,id,name)),value($type,avatarUrl,buildLink,color(id),fullName,id,isResolved,localizedName,login,minutes,name,presentation,text))&query=project:+%7Burv_zup_31%7D'";
	Попытка

		ЗапросХТТП = Новый HTTPЗапрос(ТекстЗапросаЗадачи);

		ЗапросХТТП.Заголовки.Вставить("Authorization", Токен);
		ЗапросХТТП.Заголовки.Вставить("Accept", "application/json");
		ЗапросХТТП.Заголовки.Вставить("Content-Type", "application/json");
		
		РезультатЗапроса = Соединение.Получить(ЗапросХТТП);
		ТекстСообщения = РезультатЗапроса.ПолучитьТелоКакСтроку();

	Исключение

		ТекстСообщения = ОписаниеОшибки();

	КонецПопытки;

	Если ЗначениеЗаполнено(ТекстСообщения) Тогда
		Сообщить(ТекстСообщения);
	КонецЕсли;
	
КонецПроцедуры

ОпределитьНастройки();
ПолучитьИзУдаленногоРепозитория();
ВыгрузитьВФайлыИзЕДТ();
ЗагрузитьКонфигурациюИзФайлов();
Если СтруктураПараметровТелеграм.toSend Тогда
	ПолучитьИсторию();
	ОтрпавитьИсториюКоммитов();
КонецЕсли;
// ЗадачиТрекера();
Сообщить("Готово");