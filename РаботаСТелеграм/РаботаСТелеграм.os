#Использовать "../РаботаСГитом"

Процедура ОтправитьИсториюКоммитов(СтруктураПараметровТелеграм, СтруктураГитРепозитория, 
	СтруктураПараметровЕДТ, СтруктураПараметровБазы) Экспорт

	Если СтруктураПараметровТелеграм.toSend Тогда
		РаботаСГитом.ПолучитьИсторию(СтруктураПараметровЕДТ, СтруктураГитРепозитория);
		СформироватьТекстыСообщенийИОтправить(СтруктураПараметровТелеграм, СтруктураПараметровЕДТ, СтруктураПараметровБазы);
	КонецЕсли;
	
КонецПроцедуры

Процедура СформироватьТекстыСообщенийИОтправить(СтруктураПараметровТелеграм, СтруктураПараметровЕДТ, СтруктураПараметровБазы)
	
	ФайлИсторииКоммитов = СтрЗаменить(СтруктураПараметровЕДТ.fileCommitHistory, "/", "\");
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
	ОтправитьВТелеграм(ПервоеСообщение, СтруктураПараметровТелеграм);
	Для Каждого Коммит ИЗ МассивКоммитов Цикл
		АвторПолный = СокрЛП(Коммит.Автор);
		МассивСтрокАвтора = СтроковыеФункции.РазложитьСтрокуВМассивПодстрок(АвторПолный, " ");
		Если МассивСтрокАвтора.Количество() >= 2 Тогда
			Автор = СокрЛП(МассивСтрокАвтора[0]) + " " + СокрЛП(МассивСтрокАвтора[1]);
		Иначе
			Автор = АвторПолный;
		КонецЕсли;
		
		ТекстИстории = Автор + Символы.ПС + СокрЛП(Коммит.Коммит);
		
		 ОтправитьВТелеграм(ТекстИстории, СтруктураПараметровТелеграм);
	КонецЦИкла;
	
КонецПроцедуры

Процедура ОтправитьВТелеграм(ТекстИстории, СтруктураПараметровТелеграм)
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