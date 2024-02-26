﻿// Реализация шагов BDD-фич/сценариев c помощью фреймворка https://github.com/artbear/1bdd

#Использовать asserts

Перем БДД; //контекст фреймворка 1bdd

// Метод выдает список шагов, реализованных в данном файле-шагов
Функция ПолучитьСписокШагов(КонтекстФреймворкаBDD) Экспорт
	БДД = КонтекстФреймворкаBDD;
	
	ВсеШаги = Новый Массив;
	
	ВсеШаги.Добавить("ЯПолучаюТекущуюВетку");
	ВсеШаги.Добавить("ТекущаяВеткаРавна");
	ВсеШаги.Добавить("ЯСоздаюВетку");
	ВсеШаги.Добавить("ЯПолучаюСписокВеток");
	ВсеШаги.Добавить("СписокВетокСодержитВеткуCПризнакомТекущая");
	ВсеШаги.Добавить("ЯПерехожуНаВеткуСЕеСозданием");
	ВсеШаги.Добавить("ЯПерехожуНаВетку");
	
	Возврат ВсеШаги;
КонецФункции


// Реализация шагов

// Процедура выполняется перед запуском каждого сценария
Процедура ПередЗапускомСценария(Знач Узел) Экспорт
	
КонецПроцедуры

// Процедура выполняется после завершения каждого сценария
Процедура ПослеЗапускаСценария(Знач Узел) Экспорт
	
КонецПроцедуры

//Я получаю текущую ветку
Процедура ЯПолучаюТекущуюВетку() Экспорт
	ГитРепозиторий = БДД.ПолучитьИзКонтекста("ГитРепозиторий");
	ТекущаяВетка = ГитРепозиторий.ПолучитьТекущуюВетку();
	
	БДД.СохранитьВКонтекст("ТекущаяВетка", ТекущаяВетка);
КонецПроцедуры

//Текущая ветка равна "master"
Процедура ТекущаяВеткаРавна(Знач ОжидаемаяВетка) Экспорт
	ТекущаяВетка = БДД.ПолучитьИзКонтекста("ТекущаяВетка");
	Ожидаем.Что(ТекущаяВетка).Содержит(ОжидаемаяВетка);
КонецПроцедуры

//Я перехожу на ветку "master"
Процедура ЯПерехожуНаВетку(Знач ИмяВетки) Экспорт
	ГитРепозиторий = БДД.ПолучитьИзКонтекста("ГитРепозиторий");
	ГитРепозиторий.ПерейтиВВетку(ИмяВетки);
КонецПроцедуры

//Я получаю список веток
Процедура ЯПолучаюСписокВеток() Экспорт
	ГитРепозиторий = БДД.ПолучитьИзКонтекста("ГитРепозиторий");
	СписокВеток = ГитРепозиторий.ПолучитьСписокВеток();
	БДД.СохранитьВКонтекст("СписокВеток", СписокВеток);
КонецПроцедуры

//Список веток содержит ветку "master" c признаком текущая "истина"
Процедура СписокВетокСодержитВеткуCПризнакомТекущая(Знач ИмяВетки, Знач Текущая) Экспорт
	СписокВеток = БДД.ПолучитьИзКонтекста("СписокВеток");
	
	Нашли = Ложь;
	Для Каждого Ветка Из СписокВеток Цикл
		
		Если Ветка.Имя <> ИмяВетки Тогда
			Продолжить;
		КонецЕсли;
		
		Нашли = Истина;
		Ожидаем.Что(Ветка.Текущая, "Ветка содержит неверный признак ""Текущая""").Равно(Булево(Текущая));
		
	КонецЦикла;	
	
	Ожидаем.Что(Нашли, "Список веток не содержит ветки " + ИмяВетки).ЭтоИстина();
КонецПроцедуры

//Я перехожу на ветку "develop" с ее созданием
Процедура ЯПерехожуНаВеткуСЕеСозданием(Знач ИмяВетки) Экспорт
	ГитРепозиторий = БДД.ПолучитьИзКонтекста("ГитРепозиторий");
	ГитРепозиторий.ПерейтиВВетку(ИмяВетки, Истина);
КонецПроцедуры

//Я создаю ветку "develop"
Процедура ЯСоздаюВетку(Знач ИмяВетки) Экспорт
	ГитРепозиторий = БДД.ПолучитьИзКонтекста("ГитРепозиторий");
	ГитРепозиторий.СоздатьВетку(ИмяВетки);
КонецПроцедуры
