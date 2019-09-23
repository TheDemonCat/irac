// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Требование_Ид;        // rule
Перем Требование_Позиция;    // position
Перем Требование_Параметры;

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем Сервер_Владелец;

Перем ПараметрыОбъекта;

Перем ПериодОбновления;
Перем МоментАктуальности;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера     - АгентКластера           - ссылка на родительский объект, агент кластера
//   Кластер           - Кластер                 - ссылка на родительский объект, кластер
//   Сервер            - Сервер                  - ссылка на родительский объект, сервер
//   Требование        - Строка, Соответствие    - идентификатор требования назначения в кластере 1С
//                                                 или параметры требования назначения
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Сервер, Требование)

	Если НЕ ЗначениеЗаполнено(Требование) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.НазначенияФункциональности);

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	Сервер_Владелец = Сервер;
	
	Если ТипЗнч(Требование) = Тип("Соответствие") Тогда
		Требование_Ид = Требование["rule"];
		Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Требование_Параметры, Требование);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Требование_Ид = Требование;
		МоментАктуальности = 0;
	КонецЕсли;

	ПериодОбновления = 60000;
	
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

	Если НЕ Служебный.ТребуетсяОбновление(Требование_Параметры,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"   , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторТребования", Сервер_Владелец.Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Описание"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения требования назначения функциональности, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	Служебный.ЗаполнитьПараметрыОбъекта(ЭтотОбъект, Требование_Параметры, МассивРезультатов[0]);

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

// Функция возвращает идентификатор требования назначения функциональности
//   
// Возвращаемое значение:
//    Строка - идентификатор требования назначения функциональности
//
Функция Ид() Экспорт

	Возврат Требование_Ид;

КонецФункции // Ид()

// Функция возвращает позицию требования назначения функциональности в списке (начиная с 0)
//   
// Возвращаемое значение:
//    Строка - позиция требования назначения функциональности в списке
//
Функция Позиция() Экспорт

	Если Служебный.ТребуетсяОбновление(Требование_Позиция, МоментАктуальности, ПериодОбновления) Тогда
		ОбновитьДанные(Истина);
	КонецЕсли;

	Возврат Требование_Позиция;
	
КонецФункции // Позиция()

// Функция возвращает значение параметра требования назначения функциональности
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра требования назначения функциональности
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра требования назначения функциональности
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Ид, rule"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Требование_Ид;
	КонецЕсли;

	Если НЕ Найти(ВРЕг("Позиция, position"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Требование_Позиция;
	КонецЕсли;
	
	ЗначениеПоля = Требование_Параметры.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Требование_Параметры.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
	
// Процедура изменяет параметры требования назначения функциональности
//   
// Параметры:
//   Позиция                 - Число            - позиция требования назначения функциональности в списке (начиная с 0)
//   ПараметрыТребования     - Структура        - новые параметры требования назначения функциональности
//
Процедура Изменить(Позиция, Знач ПараметрыТребования = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыТребования) = Тип("Структура") Тогда
		ПараметрыТребования = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("Идентификатортребования"  , Ид());

	ПараметрыКоманды.Вставить("Позиция"        , Позиция);

	Для Каждого ТекЭлемент Из ПараметрыТребования Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения требования назначения функциональности ""%1"": %2",
	                                Позиция,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Процедура удаляет требование назначения функциональности для сервера 1С
//   
Процедура Удалить() Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	ПараметрыКоманды.Вставить("ИдентификаторСервера"     , Сервер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ИдентификаторТребования"  , Ид());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Удалить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления требования назначения функциональности ""%1"": %2",
		                            Получить("Позиция"),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("oscript.lib.irac");
