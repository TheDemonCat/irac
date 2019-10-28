// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Сервер_Ид;    // server
Перем Сервер_Имя;    // name
Перем Сервер_АдресАгента;    // agent-host
Перем Сервер_ПортАгента;    // agent-port
Перем Сервер_Свойства;

Перем Сервер_НазначенияФункциональности;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера      - АгентКластера             - ссылка на родительский объект агента кластера
//   Кластер            - Кластер                   - ссылка на родительский объект кластера
//   Сервер             - Строка, Соответствие      - идентификатор сервера в кластере 1С или параметры сервера
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Сервер) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Серверы);

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	
	Если ТипЗнч(Сервер) = Тип("Соответствие") Тогда
		Сервер_Ид = Сервер["server"];
		ЗаполнитьПараметрыСервера(Сервер);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Сервер_Ид = Сервер;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = 60000;
	
	Сервер_НазначенияФункциональности = Новый НазначенияФункциональности(Кластер_Агент, Кластер_Владелец, ЭтотОбъект);
	
КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Сервер_Свойства,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСервера"        , Ид());
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описание сервера, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Если МассивРезультатов.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ЗаполнитьПараметрыСервера(МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура заполняет параметры сервера кластера 1С
//   
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры сервера
//   
Процедура ЗаполнитьПараметрыСервера(ДанныеЗаполнения)

	Сервер_АдресАгента = ДанныеЗаполнения.Получить("agent-host");
	Сервер_ПортАгента = ДанныеЗаполнения.Получить("agent-port");
	Сервер_Имя = ДанныеЗаполнения.Получить("name");

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Сервер_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыСервера()

// Функция возвращает коллекцию параметров объекта
//   
// Параметры:
//   ИмяПоляКлюча         - Строка    - имя поля, значение которого будет использовано
//                                      в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//    Соответствие - коллекция параметров объекта, для получения/изменения значений
//
Функция ПараметрыОбъекта(ИмяПоляКлюча = "Имя") Экспорт

	Возврат ПараметрыОбъекта.ОписаниеСвойств(ИмяПоляКлюча);

КонецФункции // ПараметрыОбъекта()

// Функция возвращает идентификатор сервера 1С
//   
// Возвращаемое значение:
//    Строка - идентификатор сервера 1С
//
Функция Ид() Экспорт

	Возврат Сервер_Ид;

КонецФункции // Ид()

// Функция возвращает имя сервера 1С
//   
// Возвращаемое значение:
//    Строка - имя сервера 1С
//
Функция Имя() Экспорт

	Если Служебный.ТребуетсяОбновление(Сервер_Имя, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Сервер_Имя;
	
КонецФункции // Имя()

// Функция возвращает адрес сервера 1С
//   
// Возвращаемое значение:
//    Строка - адрес сервера 1С
//
Функция АдресСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_АдресАгента, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Сервер_АдресАгента;
	    
КонецФункции // АдресСервера()
	
// Функция возвращает порт сервера 1С
//   
// Возвращаемое значение:
//    Строка - порт сервера 1С
//
Функция ПортСервера() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_ПортАгента, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Сервер_ПортАгента;
	    
КонецФункции // ПортСервера()
	
// Функция возвращает список требований назначения функциональности сервера 1С
//   
// Возвращаемое значение:
//    НазначенияФункциональности -  список требований назначения функциональности сервера 1С
//
Функция НазначенияФункциональности() Экспорт
	
	Если Служебный.ТребуетсяОбновление(Сервер_НазначенияФункциональности, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Сервер_НазначенияФункциональности;
	    
КонецФункции // НазначенияФункциональности()
	
// Функция возвращает значение параметра кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	ЗначениеПоля = Неопределено;

	Если НЕ Найти(ВРЕг("Ид, server"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Сервер_Ид;
	ИначеЕсли НЕ Найти(ВРЕг("Имя, name"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Сервер_Имя;
	ИначеЕсли НЕ Найти(ВРЕг("СерверАгента, agent-host"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Сервер_АдресАгента;
	ИначеЕсли НЕ Найти(ВРЕг("ПортАгента, agent-port"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Сервер_ПортАгента;
	Иначе
		ЗначениеПоля = Сервер_Свойства.Получить(ИмяПоля);
	КонецЕсли;
	
	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Сервер_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
	
// Процедура изменяет параметры сервера
//   
// Параметры:
//   ПараметрыСервера         - Структура        - новые параметры сервера
//
Процедура Изменить(Знач ПараметрыСервера = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСервера) = Тип("Структура") Тогда
		ПараметрыСервера = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторСервера"        , Ид());
	
	Для Каждого ТекЭлемент Из ПараметрыСервера Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения параметров сервера, КодВозврата = %1: %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()
