// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Кластер_Агент;
Перем Кластер_Владелец;
Перем ИБ_Владелец;
Перем Сеанс_Владелец;
Перем Соединение_Владелец;

Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера    - АгентКластера        - ссылка на родительский объект агента кластера
//   Кластер          - Кластер              - ссылка на родительский объект кластера
//   ИБ               - ИнформационнаяБаза   - ссылка на родительский объект информационной базы
//   Сеанс            - Сеанс                - ссылка на родительский объект сеанса
//   Соединение       - Соединение           - ссылка на родительский объект соединения
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ = Неопределено, Сеанс = Неопределено, Соединение = Неопределено)

	Лог = Служебный.Лог();

	Кластер_Агент        = АгентКластера;
	Кластер_Владелец     = Кластер;
	ИБ_Владелец          = ИБ;
	Сеанс_Владелец       = Сеанс;
	Соединение_Владелец  = Соединение;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Блокировки);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура получает список блокировок от утилиты администрирования кластера 1С
// и сохраняет в локальных переменных
//   
// Параметры:
//   ОбновитьПринудительно        - Булево    - Истина - принудительно обновить данные (вызов RAC)
//                                            - Ложь - данные будут получены если истекло время актуальности
//                                                    или данные не были получены ранее
//   
Процедура ОбновитьДанные(ОбновитьПринудительно = Ложь) Экспорт
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторИБ", ИБ_Владелец.Ид());
	КонецЕсли;

	Если НЕ Сеанс_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторСеанса", Сеанс_Владелец.Ид());
	КонецЕсли;

	Если НЕ Соединение_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторСоединения", Соединение_Владелец.Ид());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка блокировок, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивБлокировок = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		Блокировка = Новый ОбъектКластера(Кластер_Агент,
		                                  Кластер_Владелец,
		                                  Перечисления.РежимыАдминистрирования.Блокировки,
		                                  ТекОписание);
		МассивБлокировок.Добавить(Блокировка);
	КонецЦикла;

	Элементы.Заполнить(МассивБлокировок);

	Элементы.УстановитьАктуальность();

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

// Функция возвращает список блокировок
//   
// Параметры:
//   Отбор                     - Структура    - Структура отбора блокировок (<поле>:<значение>)
//   ОбновитьПринудительно     - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия   - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                               Строка         с именами свойств в качестве ключей
//                                              <Имя поля> - элементы результата будут преобразованы в соответствия
//                                              со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                              Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Массив - список блокировок
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Блокировки = Элементы.Список(Отбор, ОбновитьПринудительно, ЭлементыКакСоответствия);
	
	Возврат Блокировки;

КонецФункции // Список()

// Функция возвращает список блокировок
//   
// Параметры:
//   ПоляИерархии              - Строка       - Поля для построения иерархии списка блокировок, разделенные ","
//   ОбновитьПринудительно     - Булево       - Истина - принудительно обновить данные (вызов RAC)
//   ЭлементыКакСоответствия   - Булево,      - Истина - элементы результата будут преобразованы в соответствия
//                               Строка         с именами свойств в качестве ключей
//                                              <Имя поля> - элементы результата будут преобразованы в соответствия
//                                              со значением указанного поля в качестве ключей ("Имя"|"ИмяРАК")
//                                              Ложь - (по умолчанию) элементы будут возвращены как есть
//
// Возвращаемое значение:
//    Соответствие - список блокировок
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь, ЭлементыКакСоответствия = Ложь) Экспорт

	Блокировки = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно, ЭлементыКакСоответствия);

	Возврат Блокировки;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество блокировок в списке
//   
// Возвращаемое значение:
//    Число - количество блокировок
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()
