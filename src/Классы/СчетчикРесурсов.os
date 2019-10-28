// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Счетчик_Имя;
Перем Счетчик_Свойства;
Перем Счетчик_ДлительностьСбора;
Перем Счетчик_Значения;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;
Перем ПараметрыЗначений;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера    - АгентКластера           - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                 - ссылка на родительский объект кластера
//   Счетчик          - Строка, Соответствие    - имя счетчика потребления ресурсов в кластере 1С
//                                                или параметры счетчика потребления ресурсов
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Счетчик)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Счетчик) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.СчетчикиРесурсов);

	Кластер_Агент    = АгентКластера;
	Кластер_Владелец = Кластер;

	Если ТипЗнч(Счетчик) = Тип("Соответствие") Тогда
		Счетчик_Имя = Счетчик["name"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Счетчик_Свойства, Счетчик);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Счетчик_Имя = Счетчик;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = 60000;
	
	Счетчик_Значения = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает данные от сервиса администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно        - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт

	Если НЕ Служебный.ТребуетсяОбновление(Счетчик_Свойства,
		МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		 Возврат;
	 КонецЕсли;
 
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика", Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания счетчика потребления ресурсов ""%1"", КодВозврата = %2: %3",
	                                Имя(),
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Счетчик_Свойства, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура получает значения счетчика потребления ресурсов
// и сохраняет в локальных переменных
//   
// Параметры:
//    Отбор - отбор значений счетчика потребления ресурсов
//
Процедура ОбновитьДанныеЗначений(Знач Отбор = "") Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя());
	Если ЗначениеЗаполнено(Отбор) Тогда
		ПараметрыКоманды.Вставить("Отбор"                , Отбор);
	КонецЕсли;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Значения"));

	Если НЕ КодВозврата = 0 Тогда
		Если НЕ ЗначениеЗаполнено(Отбор) Тогда
			Отбор = "<без отбора>";
		КонецЕсли;
		ВызватьИсключение СтрШаблон("Ошибка получения значений счетчика потребления ресурсов ""%1""
		                            |с отбором ""%2"", КодВозврата = %3: %4",
									Имя(),
									Отбор,
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Счетчик_Значения.Заполнить(МассивРезультатов);

	Счетчик_Значения.УстановитьАктуальность();

КонецПроцедуры // ОбновитьДанныеЗначений()

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

// Функция возвращает имя счетчика потребления ресурсов
//   
// Возвращаемое значение:
//    Строка - имя счетчика потребления ресурсов
//
Функция Имя() Экспорт

	Возврат Счетчик_Имя;

КонецФункции // Имя()
	
// Функция возвращает значение параметра счетчика потребления ресурсов кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра счетчика потребления ресурсов кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Имя, name"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Счетчик_Имя;
	КонецЕсли;
	
	ЗначениеПоля = Счетчик_Свойства.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Счетчик_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()

// Процедура изменяет параметры счетчика потребления ресурсов
//   
// Параметры:
//   ПараметрыСчетчика         - Структура        - новые параметры счетчика потребления ресурсов
//
Процедура Изменить(Знач ПараметрыСчетчика = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыСчетчика) = Тип("Соответствие") Тогда
		ПараметрыСчетчика = Новый Соответствие();
	КонецЕсли;
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя());
	
	Для Каждого ТекЭлемент Из ПараметрыСчетчика Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения параметров счетчика потребления ресурсов, КодВозврата = %1: %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));
	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Функция возвращает значения счетчика потребления ресурсов
//   
// Параметры:
//    Отбор - отбор значений счетчика потребления ресурсов
//
// Возвращаемое значение:
//    ОбъектыКластера - значения счетчика потребления ресурсов
//
Функция Значения(Знач Отбор = "") Экспорт
	
	Если Счетчик_Значения.ТребуетсяОбновление(ЗначениеЗаполнено(Отбор)) Тогда
		ОбновитьДанныеЗначений(Отбор);
	КонецЕсли;

	Возврат Счетчик_Значения;
	
КонецФункции // Значения()
	
// Процедура удаляет счетчик потребления ресурсов из кластера 1С
//   
// Параметры:
//   Имя            - Строка    - Имя счетчик потребления ресурсов
//
Процедура Удалить(Имя) Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());

	ПараметрыКоманды.Вставить("ИмяСчетчика"              , Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Отключить"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления счетчика потребления ресурсов ""%1"", КодВозврата = %2: %3",
	                                Имя(),
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);
	
КонецПроцедуры // Удалить()
