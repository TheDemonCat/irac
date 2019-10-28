// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/irac/
// ----------------------------------------------------------

Перем Профиль_Имя;        // name
Перем Профиль_Свойства;

Перем Профиль_Каталоги;
Перем Профиль_COMКлассы;
Перем Профиль_ВнешниеКомпоненты;
Перем Профиль_ВнешниеМодули;
Перем Профиль_Приложения;
Перем Профиль_ИнтернетРесурсы;

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
//   Профиль          - Строка, Соответствие    - имя профиля безопасности в кластере 1С
//                                                или параметры профиля безопасности
//
Процедура ПриСозданииОбъекта(АгентКластера, Кластер, Профиль)

	Лог = Служебный.Лог();

	Если НЕ ЗначениеЗаполнено(Профиль) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыОбъекта = Новый КомандыОбъекта(Перечисления.РежимыАдминистрирования.ПрофилиБезопасности);

	Кластер_Агент    = АгентКластера;
	Кластер_Владелец = Кластер;

	Если ТипЗнч(Профиль) = Тип("Соответствие") Тогда
		Профиль_Имя = Профиль["name"];
		Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Профиль_Свойства, Профиль);
		МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Иначе
		Профиль_Имя = Профиль;
		МоментАктуальности = 0;
	КонецЕсли;

	Профиль_Каталоги            = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.Каталог);
	Профиль_COMКлассы           = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.COMКласс);
	Профиль_ВнешниеКомпоненты   = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.Компонент);
	Профиль_ВнешниеМодули       = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.Модуль);
	Профиль_Приложения          = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.Приложение);
	Профиль_ИнтернетРесурсы     = Новый ОбъектыПрофиля(Кластер_Агент, Кластер_Владелец, ЭтотОбъект,
	                                                   Перечисления.ВидыОбъектовПрофиляБезопасности.ИнтернетРесурс);
	
	ПериодОбновления = 60000;
	МоментАктуальности = 0;
	
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

	Если НЕ Служебный.ТребуетсяОбновление(Профиль_Свойства,
			МоментАктуальности, ПериодОбновления, ОбновитьПринудительно) Тогда
		Возврат;
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Список"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания профиля безопасности ""%1"": %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	МассивРезультатов = Кластер_Агент.ВыводКоманды();

	ЭлементНайден = Ложь;
	Для Каждого ТекЭлемент Из МассивРезультатов Цикл
		Если ТекЭлемент["name"] = Имя() Тогда
			ЭлементНайден = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;

	Если НЕ ЭлементНайден Тогда
		ВызватьИсключение СтрШаблон("Ошибка получения описания профиля безопасности ""%1"": %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	ЗаполнитьПараметрыПрофиля(ТекЭлемент);

	МоментАктуальности = ТекущаяУниверсальнаяДатаВМиллисекундах();

КонецПроцедуры // ОбновитьДанные()

// Процедура заполняет параметры профиля безопасности
//   
// Параметры:
//   ДанныеЗаполнения        - Соответствие        - данные, из которых будут заполнены параметры профиля
//   
Процедура ЗаполнитьПараметрыПрофиля(ДанныеЗаполнения)

	Профиль_Имя = ДанныеЗаполнения.Получить("name");

	Служебный.ЗаполнитьСвойстваОбъекта(ЭтотОбъект, Профиль_Свойства, ДанныеЗаполнения);

КонецПроцедуры // ЗаполнитьПараметрыПрофиля()

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

// Функция возвращает имя профиля безопасности 1С
//   
// Возвращаемое значение:
//    Строка - имя профиля безопасности 1С
//
Функция Имя() Экспорт

	Возврат Профиль_Имя;

КонецФункции // Имя()

// Функция возвращает список разрешенных виртуальных каталогов
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных виртуальных каталогов
//
Функция Каталоги() Экспорт
	
	Возврат Профиль_Каталоги;
	
КонецФункции // Каталоги()
	
// Функция возвращает список разрешенных COM-классов
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных COM-Классов
//
Функция COMКлассы() Экспорт
	
	Возврат Профиль_COMКлассы;
	
КонецФункции // COMКлассы()
	
// Функция возвращает список разрешенных внешних компонент
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных внешних компонент
//
Функция ВнешниеКомпоненты() Экспорт
	
	Возврат Профиль_ВнешниеКомпоненты;
	
КонецФункции // ВнешниеКомпоненты()
	
// Функция возвращает список разрешенных внешних модулей
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных внешних модулей
//
Функция ВнешниеМодули() Экспорт
	
	Возврат Профиль_ВнешниеМодули;
	
КонецФункции // ВнешниеМодули()
	
// Функция возвращает список разрешенных приложений
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных приложений
//
Функция Приложения() Экспорт
	
	Возврат Профиль_Приложения;
	
КонецФункции // Приложения()
	
// Функция возвращает список разрешенных ресурсов интернет
//   
// Возвращаемое значение:
//    ОбъектыПрофиля - список разрешенных ресурсов интернет
//
Функция ИнтернетРесурсы() Экспорт
	
	Возврат Профиль_ИнтернетРесурсы;
	
КонецФункции // ИнтернетРесурсы()
	
// Функция возвращает значение параметра профиля безопасности кластера 1С
//   
// Параметры:
//   ИмяПоля                 - Строка        - Имя параметра кластера
//   ОбновитьПринудительно     - Булево        - Истина - обновить список (вызов RAC)
//
// Возвращаемое значение:
//    Произвольный - значение параметра профиля безопасности кластера 1С
//
Функция Получить(ИмяПоля, ОбновитьПринудительно = Ложь) Экспорт
	
	ОбновитьДанные(ОбновитьПринудительно);

	Если НЕ Найти(ВРЕг("Имя, name"), ВРег(ИмяПоля)) = 0 Тогда
		Возврат Профиль_Имя;
	КонецЕсли;
	
	ЗначениеПоля = Профиль_Свойства.Получить(ИмяПоля);

	Если ЗначениеПоля = Неопределено Тогда
	    
		ОписаниеПараметра = ПараметрыОбъекта("ИмяРАК").Получить(ИмяПоля);

		Если НЕ ОписаниеПараметра = Неопределено Тогда
			ЗначениеПоля = Профиль_Свойства.Получить(ОписаниеПараметра["Имя"]);
		КонецЕсли;
	КонецЕсли;

	Возврат ЗначениеПоля;
	    
КонецФункции // Получить()
	
// Процедура изменяет режим доступа к объектам профиля (список/полный доступ)
//   
// Параметры:
//   ВидОбъектовПрофиля       - Перечисление.            - вид объекта профиля для изменения режима доступа
//                              ВидыОбъектовПрофиляБезопасности
//   РежимДоступа             - Перечисление.            - устанавливаемый режим доступа
//                              РежимДоступа
//
Процедура ИзменитьРежимДоступаКОбъектам(ВидОбъектовПрофиля, РежимДоступа) Экспорт

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	ПараметрыКоманды.Вставить("Имя"                         , Имя());
	ПараметрыКоманды.Вставить("ВидОбъектовПрофиля"          , ВидОбъектовПрофиля);
	ПараметрыКоманды.Вставить("РежимДоступа"                , РежимДоступа);

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("ИзменитьРежимДоступа"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения режима доступа объекта ""%1"" профиля ""%2"" на ""%3"": %4",
		                            ВидОбъектовПрофиля,
		                            Имя(),
		                            РежимДоступа,
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

КонецПроцедуры // ИзменитьРежимДоступаКОбъектам()

// Процедура изменяет параметры профиля безопасности
//   
// Параметры:
//   ПараметрыПрофиля         - Структура        - новые параметры профиля безопасности
//
Процедура Изменить(Знач ПараметрыПрофиля = Неопределено) Экспорт

	Если НЕ ТипЗнч(ПараметрыПрофиля) = Тип("Структура") Тогда
		ПараметрыПрофиля = Новый Структура();
	КонецЕсли;

	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"          , Имя());

	Для Каждого ТекЭлемент Из ПараметрыПрофиля Цикл
		ПараметрыКоманды.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
	КонецЦикла;

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Изменить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка изменения профиля безопасности ""%1"": %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;

	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

	ОбновитьДанные(Истина);

КонецПроцедуры // Изменить()

// Процедура удаляет информационную базу
//   
Процедура Удалить() Экспорт
	
	ПараметрыКоманды = Новый Соответствие();
	ПараметрыКоманды.Вставить("СтрокаПодключенияАгента"     , Кластер_Агент.СтрокаПодключения());
	ПараметрыКоманды.Вставить("ИдентификаторКластера"       , Кластер_Владелец.Ид());
	ПараметрыКоманды.Вставить("ПараметрыАвторизацииКластера", Кластер_Владелец.ПараметрыАвторизации());
	
	ПараметрыКоманды.Вставить("Имя"     , Имя());

	ПараметрыОбъекта.УстановитьЗначенияПараметровКоманд(ПараметрыКоманды);

	КодВозврата = Кластер_Агент.ВыполнитьКоманду(ПараметрыОбъекта.ПараметрыКоманды("Удалить"));

	Если НЕ КодВозврата = 0 Тогда
		ВызватьИсключение СтрШаблон("Ошибка удаления профиля безопасности ""%1"": %2",
	                                Имя(),
	                                Кластер_Агент.ВыводКоманды(Ложь));
	КонецЕсли;
	
	Лог.Отладка(Кластер_Агент.ВыводКоманды(Ложь));

КонецПроцедуры // Удалить()
