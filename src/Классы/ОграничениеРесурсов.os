// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Ограничение_Имя;
Перем Ограничение_Свойства;
Перем Ограничение_ДлительностьСбора;
Перем Ограничение_Значения;

Перем Кластер_Агент;
Перем Кластер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера    - АгентКластера           - ссылка на родительский объект агента кластера
//   Кластер          - Кластер                 - ссылка на родительский объект кластера
//   Ограничение      - Строка, Соответствие    - имя ограничения потребления ресурсов в кластере 1С
//                                                или параметры ограничения потребления ресурсов
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Ограничение)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Ограничение) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.ОграниченияРесурсов);

	Кластер_Агент    = АгентКластера;
	Кластер_Владелец = Кластер;

	Если ТипЗнч(Ограничение) = Тип("Соответствие") Тогда
		Ограничение_Имя = Ограничение["name"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Ограничение_Свойства, Ограничение);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Ограничение_Имя = Ограничение;
		МоментАктуальности = 0;
	КонецЕсли;
	
	ПериодОбновления = 60000;
	
	Ограничение_Значения = Новый ОбъектыКластера(ЭтотОбъект);

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

	Если НЕ Служебный.ТребуетсяОбновление(Ограничение_Свойства,
		МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		 Возврат;
	 КонецЕсли;
 
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("ИмяОграничения", Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания ограничения потребления ресурсов ""%1"", КодВозврата = %2: %3",
	                                Имя(),
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Ограничение_Свойства, МассивРезультатов[0]);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

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

// Функция возвращает имя ограничения потребления ресурсов
//   
// Возвращаемое значение:
//    Строка - имя ограничения потребления ресурсов
//
Функция Имя() Экспорт

	Возврат Ограничение_Имя;

КонецФункции // Имя()
	
// Функция возвращает значение параметра ограничения потребления ресурсов кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра ограничения потребления ресурсов кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Имя, name"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Ограничение_Имя;
	КонецЕсли;
	
	ЗначениеПоля = Ограничение_Свойства.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Ограничение_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()

// Процедура изменяет параметры ограничения потребления ресурсов
//   
// Параметры:
//   ПараметрыОграничения      - Структура        - новые параметры ограничения потребления ресурсов
//
Процедура Изменить(Знач ПараметрыОграничения = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыОграничения) = Тип("Соответствие") Тогда
		ПараметрыОграничения = Новый Соответствие();
	КонецЕсли;
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	
	ПараметрыКоманды.Вставить("ИмяОграничения"           , Имя());
	
	Для Каждого ТекЭлемент Из ПараметрыОграничения Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;
	
	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения параметров ограничения потребления ресурсов, КодВозврата = %1: %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));
	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Процедура удаляет ограничение потребления ресурсов из кластера 1С
//   
// Параметры:
//   Имя            - Строка    - Имя ограничения потребления ресурсов
//
Процедура Удалить(Имя) Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());

	ПараметрыКоманды.Вставить("ИмОграничения"            , Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Отключить"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления ограничения потребления ресурсов ""%1"", КодВозврата = %2: %3",
	                                Имя(),
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);
	
КонецПроцедуры // Удалить()
