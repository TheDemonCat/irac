﻿#Использовать "../src"
#Использовать asserts

Перем ЮнитТест;
Перем АгентКластера;
Перем Кластер;

// Функция возвращает список тестов для выполнения
//
// Параметры:
//	Тестирование	
Функция ПолучитьСписокТестов(Тестирование) Экспорт
	
	ЮнитТест = Тестирование;
	
	СписокТестов = Новый Массив;
	СписокТестов.Добавить("ТестДолжен_СоздатьАгентКластера");
	СписокТестов.Добавить("ТестДолжен_СоздатьАдминистраторыАгента");
	СписокТестов.Добавить("ТестДолжен_СоздатьКластеры");
	СписокТестов.Добавить("ТестДолжен_СоздатьКластер");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыКластера");
	СписокТестов.Добавить("ТестДолжен_СоздатьАдминистраторыКластера");
	СписокТестов.Добавить("ТестДолжен_СоздатьСерверыКластера");
	СписокТестов.Добавить("ТестДолжен_СоздатьСервер");
	СписокТестов.Добавить("ТестДолжен_СоздатьМенеджерыКластера");
	СписокТестов.Добавить("ТестДолжен_СоздатьРабочиеПроцессы");
	СписокТестов.Добавить("ТестДолжен_СоздатьРабочийПроцесс");
	СписокТестов.Добавить("ТестДолжен_СоздатьСервисы");
	СписокТестов.Добавить("ТестДолжен_СоздатьСеансы");
	СписокТестов.Добавить("ТестДолжен_СоздатьСоединения");
	СписокТестов.Добавить("ТестДолжен_СоздатьБлокировки");
	СписокТестов.Добавить("ТестДолжен_СоздатьИнформационныеБазы");
	СписокТестов.Добавить("ТестДолжен_СоздатьИнформационнаяБаза");
	СписокТестов.Добавить("ТестДолжен_ВызватьСлужебный");
	СписокТестов.Добавить("ТестДолжен_ПолучитьПеречисления");
	СписокТестов.Добавить("ТестДолжен_СоздатьНазначенияФункциональности");
	СписокТестов.Добавить("ТестДолжен_СоздатьНазначениеФункциональности");
	СписокТестов.Добавить("ТестДолжен_СоздатьПрофилиБезопасности");
	СписокТестов.Добавить("ТестДолжен_СоздатьПрофильБезопасности");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляКаталог");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляCOMКласс");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляКомпонента");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляМодуль");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляПриложение");
	СписокТестов.Добавить("ТестДолжен_СоздатьОбъектыПрофиляИнтернетРесурс");

	Возврат СписокТестов;
	
КонецФункции

// Процедура выполняется после запуска теста
//
Процедура ПослеЗапускаТеста() Экспорт

	
КонецПроцедуры // ПослеЗапускаТеста()

// Процедура выполняется после запуска теста
//
Процедура ПередЗапускомТеста() Экспорт
	

КонецПроцедуры

// Процедура - тест
//
Процедура ТестДолжен_СоздатьАгентКластера() Экспорт
	
	АгентКластера = Новый АдминистрированиеКластера(Неопределено, Неопределено, "8.3");

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

Процедура ТестДолжен_СоздатьАдминистраторыАгента() Экспорт
	
	АдминистраторыАгента = Новый АдминистраторыАгента(АгентКластера);

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьКластеры() Экспорт
	
	Кластеры = Новый Кластеры(АгентКластера);

КонецПроцедуры // ТестДолжен_СоздатьКластеры()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьКластер() Экспорт
	
	Кластер = Новый Кластер(Неопределено, "");

КонецПроцедуры // ТестДолжен_СоздатьКластер()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыКластера() Экспорт
	
	ОбъектыКластера = Новый ОбъектыКластера(Неопределено);

КонецПроцедуры // ТестДолжен_СоздатьОбъектыКластера()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьАдминистраторыКластера() Экспорт
	
	АдминистраторыКластера = Новый АдминистраторыКластера(Неопределено, Неопределено);

КонецПроцедуры // ТестДолжен_СоздатьАдминистраторыКластера()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьСерверыКластера() Экспорт
	
	СерверыКластера = Новый СерверыКластера(Неопределено, Неопределено);

КонецПроцедуры // ТестДолжен_СоздатьСерверыКластера()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьСервер() Экспорт
	
	Сервер = Новый Сервер(Неопределено, Неопределено, "");

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьМенеджерыКластера() Экспорт
	
	МенеджерыКластера = Новый МенеджерыКластера(Неопределено, неопределено);

КонецПроцедуры // ТестДолжен_СоздатьМенеджерыКластера()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьРабочиеПроцессы() Экспорт
	
	ТестДолжен_СоздатьРабочиеПроцессы = Новый РабочиеПроцессы(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_СоздатьРабочиеПроцессы()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьРабочийПроцесс() Экспорт
	
	РабочийПроцесс = Новый РабочийПроцесс(АгентКластера, Кластер, "");

КонецПроцедуры // ТестДолжен_СоздатьРабочийПроцесс()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьСервисы() Экспорт
	
	Сервисы = Новый Сервисы(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_СоздатьСервисы()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьСеансы() Экспорт
	
	Сеансы = Новый Сеансы(АгентКластера, Кластер, "");

КонецПроцедуры // ТестДолжен_СоздатьСеансы()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьСоединения() Экспорт
	
	Соединения = Новый Соединения(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_СоздатьСоединения()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьБлокировки() Экспорт
	
	Блокировки = Новый Блокировки(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_ПодключитьсяКСерверуАдминистрирования()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьИнформационныеБазы() Экспорт
	
	ИнформационныеБазы = Новый ИнформационныеБазы(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_СоздатьИнформационныеБазы()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьИнформационнаяБаза() Экспорт
	
	ИнформационнаяБаза = Новый ИнформационнаяБаза(АгентКластера, Кластер, "");

КонецПроцедуры // ТестДолжен_СоздатьИнформационнаяБаза()

// Процедура - тест
//
Процедура ТестДолжен_ВызватьСлужебный() Экспорт
	
	АВКавычках =  Служебный.ОбернутьВКавычки("А");

КонецПроцедуры // ТестДолжен_ВызватьСлужебный()

// Процедура - тест
//
Процедура ТестДолжен_ПолучитьПеречисления() Экспорт
	
	ВариантыИспользованияРабочегоСервера = Перечисления.ВариантыИспользованияРабочегоСервера;

КонецПроцедуры // ТестДолжен_ПолучитьПеречисления()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьНазначенияФункциональности() Экспорт
	
	ИнформационныеБазы = Новый НазначенияФункциональности(АгентКластера, Кластер, Неопределено);

КонецПроцедуры // ТестДолжен_СоздатьНазначенияФункциональности()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьНазначениеФункциональности() Экспорт
	
	ИнформационнаяБаза = Новый НазначениеФункциональности(АгентКластера, Кластер, Неопределено, "");

КонецПроцедуры // ТестДолжен_СоздатьНазначениеФункциональности()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьПрофилиБезопасности() Экспорт
	
	Профили = Новый ПрофилиБезопасности(АгентКластера, Кластер);

КонецПроцедуры // ТестДолжен_СоздатьПрофилиБезопасности()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьПрофильБезопасности() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");

КонецПроцедуры // ТестДолжен_СоздатьПрофильБезопасности()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляКаталог() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "directory");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляКаталог()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляCOMКласс() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "com");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляCOMКласс()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляКомпонента() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "addin");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляКомпонента()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляМодуль() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "module");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляМодуль()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляПриложение() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "app");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляПриложение()

// Процедура - тест
//
Процедура ТестДолжен_СоздатьОбъектыПрофиляИнтернетРесурс() Экспорт
	
	Профиль = Новый ПрофильБезопасности(АгентКластера, Кластер, "");
	ОбъектПрофиля = Новый ОбъектыПрофиля(АгентКластера, Кластер, Профиль, "inet");

КонецПроцедуры // ТестДолжен_СоздатьОбъектыПрофиляИнтернетРесурс()
