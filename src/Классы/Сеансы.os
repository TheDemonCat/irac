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
Перем ПараметрыОбъекта;
Перем Элементы;

Перем Лог;

// Конструктор
//   
// Параметры:
//   АгентКластера    - АгентКластера            - ссылка на родительский объект агента кластера
//   Кластер        - Кластер                - ссылка на родительский объект кластера
//   ИБ                - ИнформационнаяБаза    - ссылка на родительский объект информационной базы
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, ИБ = Неопределено)

	Кластер_Агент = АгентКластера;
	Кластер_Владелец = Кластер;
	ИБ_Владелец = ИБ;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.Сеансы);

	Элементы = Новый ОбъектыКластера(ЭтотОбъект);

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
	
	Если НЕ Элементы.ТребуетсяОбновление(ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"  , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"    , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("СтрокаАвторизацииКластера", Кластер_Владелец.СтрокаАвторизации());
	
	Если НЕ ИБ_Владелец = Неопределено Тогда
		ПараметрыКоманды.Вставить("ИдентификаторИБ", ИБ_Владелец.Ид());
	КонецЕсли;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));
	
	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения списка сеансов, КодВозврата = %1: %2",
	                                КодВозврата,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	МассивСеансов = Новый Массив();
	Для Каждого ТекОписание Из МассивРезультатов Цикл
		МассивСеансов.Добавить(Новый Сеанс(Кластер_Агент, Кластер_Владелец, ИБ_Владелец, ТекОписание));
	КонецЦикла;

	Элементы.Заполнить(МассивСеансов);

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

// Функция возвращает список сеансов
//   
// Параметры:
//   Отбор                         - Структура    - Структура отбора сеансов (<поле>:<значение>)
//   ОбновитьПринудительно         - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Массив - список сеансов
//
Функция Список(Отбор = Неопределено, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);
	
	Возврат Сеансы;

КонецФункции // Список()

// Функция возвращает список сеансов
//   
// Параметры:
//   ПоляИерархии            - Строка        - Поля для построения иерархии списка сеансов, разделенные ","
//   ОбновитьПринудительно    - Булево        - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - список сеансов
//
Функция ИерархическийСписок(Знач ПоляИерархии, ОбновитьПринудительно = Ложь) Экспорт

	Сеансы = Элементы.ИерархическийСписок(ПоляИерархии, ОбновитьПринудительно);

	Возврат Сеансы;

КонецФункции // ИерархическийСписок()

// Функция возвращает количество сеансов в списке
//   
// Возвращаемое значение:
//    Число - количество сеансов
//
Функция Количество() Экспорт

	Если Элементы = Неопределено Тогда
		Возврат 0;
	КонецЕсли;
	
	Возврат Элементы.Количество();

КонецФункции // Количество()

// Функция возвращает описание сеанса кластера 1С
//   
// Параметры:
//   Сеанс                     - Строка    - Номер сеанса в виде <имя информационной базы>:<номер сеанса>
//   ОбновитьПринудительно     - Булево    - Истина - принудительно обновить данные (вызов RAC)
//
// Возвращаемое значение:
//    Соответствие - описание сеанса 1С
//
Функция Получить(Знач Сеанс, Знач ОбновитьПринудительно = Ложь) Экспорт

	Сеанс = СтрРазделить(Сеанс, ":");

	Если Сеанс.Количество() = 1 Тогда
		Если ТипЗнч(Сеанс[0]) = Тип("Строка") Тогда
			Сеанс.Добавить(1);
		ИначеЕсли ТипЗнч(Сеанс[0]) = Тип("Число") Тогда
			Если ИБ_Владелец = Неопределено Тогда
				Возврат Неопределено;
			КонецЕсли;
			Сеанс.Вставить(0, ИБ_Владелец.Получить("name"));
		Иначе
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;

	ИБ = Кластер_Владелец.ИнформационныеБазы().Получить(Сеанс[0]);

	Отбор = Новый Соответствие();
	Отбор.Вставить("infobase",  ИБ.Получить("infobase"));
	Отбор.Вставить("session-id", Сеанс[1]);

	Сеансы = Элементы.Список(Отбор, ОбновитьПринудительно);

	Возврат Сеансы[0];

КонецФункции // Получить()

// Процедура удаляет сеанс
//   
// Параметры:
//   Сеанс     - Сеанс, Строка   - Сеанс или номер сеанса в виде <имя информационной базы>:<номер сеанса>
//
Процедура Удалить(Знач Сеанс) Экспорт
	
	Если ТипЗнч(Сеанс) = Тип("Строка") Тогда
		Сеанс = Получить(Сеанс);
	КонецЕсли;

	Сеанс.Завершить();

	ОбновитьДанные(Истина);

КонецПроцедуры // Удалить()

Лог = Логирование.ПолучитьЛог("oscript.lib.irac");
