Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Элементы;
Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера		- АгентКластера	- ссылка на родительский объект агента кластера
//   Кластер			- Кластер		- ссылка на родительский объект кластера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;

	ОбновитьДанные();

КонецПроцедуры

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
Процедура ОбновитьДанные()
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("server");
	ПараметрыЗапуска.Добавить("list");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	МассивРезультатов = Служебный.РазобратьВыводКоманды(Служебный.ВыводКоманды());

	Элементы = Новый Соответствие();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Элементы.Вставить(ТекОписание["name"], Новый Сервер(Кластер_Агент, Кластер_Владелец, ТекОписание["server"]));
	КонецЦикла;

КонецПроцедуры // ОбновитьДанные()

// Функция возвращает список серверов кластера 1С
//   
// Параметры:
//   ОбновитьДанные 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - список серверов кластера 1С
//
Функция ПолучитьСписок(ОбновитьДанные = Ложь) Экспорт

	Если ОбновитьДанные Тогда
		ОбновитьДанные();
	КонецЕсли;

	Возврат Элементы;

КонецФункции // ПолучитьСписок()

// Функция возвращает описание сервера кластера 1С
//   
// Параметры:
//   Имя			 	- Строка		- Имя сервера кластера 1С
//   ОбновитьДанные 	- Булево		- Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//	Соответствие - описание сервера кластера 1С
//
Функция Получить(Имя, ОбновитьДанные = Ложь) Экспорт

	Если ОбновитьДанные Тогда
		ОбновитьДанные();
	КонецЕсли;

	Возврат Элементы[Имя];

КонецФункции // Получить()

// Процедура добавляет новый сервер в кластер 1С
//   
// Параметры:
//   Имя			 	- Строка		- имя сервера 1С
//   Сервер			 	- Строка		- адрес сервера 1С
//   Порт			 	- Число			- порт сервера 1С
//   ПараметрыСервера 	- Структура		- параметры сервера 1С
//
Процедура Добавить(Имя, Сервер = "localhost", Порт = 1541, ПараметрыСервера = Неопределено) Экспорт

	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("server");
	ПараметрыЗапуска.Добавить("insert");

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Кластер_Владелец.СтрокаАвторизации());

	ПараметрыЗапуска.Добавить(СтрШаблон("--agent-host=%1", Сервер));
	ПараметрыЗапуска.Добавить(СтрШаблон("--agent-port=%1", Порт));
	ПараметрыЗапуска.Добавить(СтрШаблон("--name=%1", Имя));

	ПараметрыОбъекта = ПолучитьСтруктуруПараметровОбъекта();

	Для Каждого ТекЭлемент Из ПараметрыОбъекта Цикл
		ЗначениеПараметра = Служебный.ПолучитьЗначениеИзСтруктуры(ПараметрыСервера, ТекЭлемент.Ключ, 0);
		ПараметрыЗапуска.Добавить(СтрШаблон(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ЗначениеПараметра));
	КонецЦикла;

	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Добавить()

// Процедура удаляет сервер из кластера 1С
//   
// Параметры:
//   Имя			 	- Строка		- имя сервера 1С
//
Процедура Удалить(Имя) Экспорт
	
	ПараметрыЗапуска = Новый Массив();
	ПараметрыЗапуска.Добавить(Кластер_Агент.СтрокаПодключения());

	ПараметрыЗапуска.Добавить("server");
	ПараметрыЗапуска.Добавить("remove");

	ПараметрыЗапуска.Добавить(СтрШаблон("--server=%1", Получить(Имя).Ид()));

	ПараметрыЗапуска.Добавить(СтрШаблон("--cluster=%1", Кластер_Владелец.Ид()));
	ПараметрыЗапуска.Добавить(Получить(Имя).СтрокаАвторизации());
	
	Служебный.ВыполнитьКоманду(ПараметрыЗапуска);
	
	Лог.Информация(Служебный.ВыводКоманды());

	ОбновитьДанные();

КонецПроцедуры // Удалить()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПолучитьСтруктуруПараметровОбъекта(ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураПараметров = Новый Соответствие();

	ДиапазонПортов = 1561;
	КоличествоИБНаПроцесс = 8;
	КоличествоСоединенийНаПроцесс = 128;
	ПортГлавногоМенеджераКластера = 1541;

	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ДиапазонПортов"						, "port-range"							, ДиапазонПортов);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ЦентральныйСервер"						, "using"								, Перечисления.ВариантыИспользованияРабочегоСервера.Главный);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"МенеджерПодКаждыйСервис"				, "dedicate-managers"					, Перечисления.ВариантыРазмещенияСервисов.ВОдномМенеджере);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КоличествоИБНаПроцесс"					, "infobases-limit"						, КоличествоИБНаПроцесс);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"МаксОбъемПамятиРабочихПроцессов"		, "memory-limit"						, 0);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"КоличествоСоединенийНаПроцесс"			, "connections-limit"					, КоличествоСоединенийНаПроцесс);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БезопасныйОбъемПамятиРабочихПроцессов"	, "safe-working-processes-memory-limit"	, 0);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"БезопасныйРасходПамятиЗаОдинВызов"		, "safe-call-memory-limit"				, 0);
	Служебный.ДобавитьПараметрОписанияОбъекта(СтруктураПараметров, ИмяПоляКлюча,
			"ПортГлавногоМенеджераКластера"			, "cluster-port"						, ПортГлавногоМенеджераКластера);

	Возврат СтруктураПараметров;

КонецФункции // ПолучитьСтруктуруПараметровОбъекта()

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
