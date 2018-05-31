// Класс хранящий структуру свойств и команд объекта указанного типа
// Доступны типы:
//		agent.admin		- Агент.Администратор
//		cluster			- Кластер
//		cluster.admin	- Кластер.Администратор
//		lock			- Блокировка
//		infobase		- ИБ
//		manager			- МенеджерКластера
//		process			- РабочийПроцесс
//		server			- Сервер
//		service			- Сервис
//		session			- Сеанс
//		connection		- Соединение
//		process.license	- РабочийПроцесс.Лицензия
//		session.license	- Сеанс.Лицензия
//		rule			- ТребованиеНазначения
//		profile			- Профиль
//		profile.directory	- Профиль.Каталог
//		profile.com			- Профиль.COMКласс
//		profile.addin		- Профиль.Компонент
//		profile.module		- Профиль.Модуль
//		profile.app			- Профиль.Приложение
//		profile.inet		- Профиль.ИнтернетРесурс

Перем ТипОбъекта; // наименование типа объектов (Кластер, Сервер, ИБ и т.п.)
Перем ОписаниеСвойств; // структура описания свойств объектов
Перем ПолучениеПараметровОбъектов; // структура описания методов заполнения списка свойств и команд объекта
Перем ПараметрыЗапуска; // массив параметров запуска команды утилиты RAC
Перем ЗначенияПараметров; // значения именованых параметров объекта

Перем Лог;

#Область ПрограммныйИнтерфейс

// Конструктор
//   
// Параметры:
//   ИмяТипаОбъекта                 - Строка        - имя типа объекта для которого создается структура параметров
//   ЗначенияПараметровКоманд       - Структура     - список параметров команд:
//                                                       Ключ - имя параметра
//                                                       Значение - значение параметра
//
Процедура ПриСозданииОбъекта(ИмяТипаОбъекта, ЗначенияПараметровКоманд = Неопределено)

	ЗаполнитьПолучениеПараметровОбъекта();

	ТипОбъекта = ПолучениеПараметровОбъектов[ВРег(ИмяТипаОбъекта)]["ИмяТипа"];

	ПроцедураЗаполнения = ПолучениеПараметровОбъектов[ВРег(ТипОбъекта)]["Параметры"];

	Если НЕ ПроцедураЗаполнения = Неопределено Тогда
		Рефлектор = Новый Рефлектор();
		Рефлектор.ВызватьМетод(ЭтотОбъект, ПроцедураЗаполнения, Новый Массив());
	КонецЕсли;

	УстановитьЗначенияПараметровКоманд(ЗначенияПараметровКоманд);

КонецПроцедуры // ПриСозданииОбъекта()

// Процедура устанавливает значения параметров команд
//   
// Параметры:
//   ЗначенияПараметровКоманд       - Структура     - список параметров команд:
//                                                       Ключ - имя параметра
//                                                       Значение - значение параметра
//   Очистить                       - Булево        - Истина - очистить значения параметров перед заполнением
//                                                    Ложь - добавить параметры к существующим
//                                                          (одноименные будут перезаполнены)
//
Процедура УстановитьЗначенияПараметровКоманд(Знач ЗначенияПараметровКоманд, Знач Очистить = Ложь) Экспорт

	Если НЕ ТипЗнч(ЗначенияПараметров) = Тип("Соответствие") ИЛИ Очистить Тогда
		ЗначенияПараметров = Новый Соответствие();
	КонецЕсли;

	Если ТипЗнч(ЗначенияПараметровКоманд) = Тип("Соответствие") Тогда
		Для Каждого ТекЭлемент Из ЗначенияПараметровКоманд Цикл
			ЗначенияПараметров.Вставить(ТекЭлемент.Ключ, ТекЭлемент.Значение);
		КонецЦикла;
	КонецЕсли;

КонецПроцедуры // УстановитьЗначенияПараметровКоманд()

// Функция возвращает коллекцию описаний свойств объекта
//   
// Параметры:
//   ИмяПоляКлюча 		- Строка	- имя поля, значение которого будет использовано
//									  в качестве ключа возвращаемого соответствия
//   
// Возвращаемое значение:
//	Соответствие - коллекция описаний свойств объекта, для получения/изменения значений
//
Функция ОписаниеСвойств(Знач ИмяПоляКлюча = "ИмяПараметра") Экспорт
	
	СтруктураОписаний = Новый Соответствие();

	Если НЕ ТипЗнч(ОписаниеСвойств) = Тип("Массив") Тогда
		Возврат СтруктураОписаний;
	КонецЕсли;

	Для Каждого ТекОписание Из ОписаниеСвойств Цикл
		СтруктураОписаний.Вставить(ТекОписание[ИмяПоляКлюча], ТекОписание);
	КонецЦикла;

	Возврат СтруктураОписаний;

КонецФункции // ОписаниеСвойств()

// Функция выполняет заполнение массива параметров запуска команды
// и возвращает результирующий массив
//   
// Параметры:
//   ИмяКоманды 		- Строка	- имя команды для которой выпоняется заполнение
//   
// Возвращаемое значение:
//	Массив - параметры запуска команды
//
Функция ПараметрыКоманды(Знач ИмяКоманды) Экспорт
	
	ПроцедураЗаполнения = ПолучениеПараметровОбъектов[ВРег(ТипОбъекта)]["Команды"][ВРег(ИмяКоманды)]["Параметры"];

	Если НЕ ПроцедураЗаполнения = Неопределено Тогда
		Рефлектор = Новый Рефлектор();
		Попытка
			Рефлектор.ВызватьМетод(ЭтотОбъект, ПроцедураЗаполнения, Новый Массив());
		Исключение
			ВызватьИсключение
				СтрШаблон("Не реализован метод получения параметров команды ""%1"" объекта ""%2"" (%3()): %4 %5",
						  ИмяКоманды,
						  ТипОбъекта,
						  ПроцедураЗаполнения,
						  Символы.ПС,
						  ИнформацияОбОшибке());
		КонецПопытки;
	КонецЕсли;

	Возврат ПараметрыЗапуска;

КонецФункции // ПараметрыКоманды()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПроцедурыЗаполненияПараметровОбъектов

#Область ИнформационныеБазы

// Процедура заполняет массив описаний свойств информационной базы
//
Процедура Параметры_ИБ_Свойства() Экспорт

	ДобавитьОписаниеСвойстваОбъекта("Ид"									, "infobase");
	ДобавитьОписаниеСвойстваОбъекта("ТипСУБД"								, "dbms",
									Перечисления.ТипыСУБД.MSSQLServer, "Чтение, Добавление, Изменение");

	ДобавитьОписаниеСвойстваОбъекта("АдресСервераСУБД"						, "db-server", "localhost",
									"Чтение, Добавление, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ИмяБазыСУБД"							, "db-name", ,
									"Чтение, Добавление, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ИмяПользователяБазыСУБД"				, "db-user", "sa",
									"Чтение, Добавление, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ПарольПользователяБазыСУБД"			, "db-pwd", ,
									"Добавление, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("НачалоБлокировкиСеансов"				, "denied-from", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ОкончаниеБлокировкиСеансов"			, "denied-to", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("СообщениеБлокировкиСеансов"			, "denied-message", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ПараметрБлокировкиСеансов"				, "denied-parameter", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("КодРазрешения"							, "permission-code", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("БлокировкаСеансовВключена"				, "sessions-deny", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("БлокировкаРегламентныхЗаданийВключена"	, "scheduled-jobs-deny",
									Перечисления.СостоянияВыключателя.Выключено,
									"Чтение, Добавление, Изменение");

	ДобавитьОписаниеСвойстваОбъекта("ВыдачаЛицензийСервером"				, "license-distribution",
									Перечисления.ПраваДоступа.Разрешено,
									"Чтение, Добавление, Изменение");
	
	ДобавитьОписаниеСвойстваОбъекта("ПараметрыВнешнегоУправленияСеансами",
									"external-session-manager-connection-string", ,
									"Чтение, Изменение");
	
	ДобавитьОписаниеСвойстваОбъекта("ОбязательноеВнешнееУправлениеСеансами"	, "external-session-manager-required",
									Перечисления.ДаНет.Нет,
									"Чтение, Изменение");

	ДобавитьОписаниеСвойстваОбъекта("ПрофильБезопасности"					, "security-profile-name", ,
									"Чтение, Изменение");
									
	ДобавитьОписаниеСвойстваОбъекта("ПрофильБезопасностиБезопасногоРежима"	, "safe-mode-security-profile-name", ,
	                                "Чтение, Изменение");

КонецПроцедуры // Параметры_ИБ_Свойства()

// Процедура заполняет общие параметры запуска команд информационных баз
//
Процедура Параметры_ИБ_Общие()

	ПараметрыЗапуска = Новый Массив();

	ДобавитьПараметрПоИмени("СтрокаПодключенияАгента");

	ДобавитьПараметрСтроку("infobase");

	ДобавитьПараметрПоШаблону("--cluster=%1", "ИдентификаторКластера");
	ДобавитьПараметрПоИмени("СтрокаАвторизацииКластера");

КонецПроцедуры // Параметры_ИБ_Общие()

// Процедура заполняет параметры команды получения списка информационных баз
//
Процедура Параметры_ИБ_Список() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("summary");
	ДобавитьПараметрСтроку("list");

КонецПроцедуры // Параметры_ИБ_Список()

// Процедура заполняет параметры команды получения сокращенного описания информационной базы
//
Процедура Параметры_ИБ_Описание() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("summary");
	ДобавитьПараметрСтроку("info");
	ДобавитьПараметрПоШаблону("--infobase=%1", "ИдентификаторИБ");

КонецПроцедуры // Параметры_ИБ_Описание()

// Процедура заполняет параметры команды получения полного описания информационной базы
//
Процедура Параметры_ИБ_ПолноеОписание() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("info");
	ДобавитьПараметрПоШаблону("--infobase=%1", "ИдентификаторИБ");
	ДобавитьПараметрПоИмени("СтрокаАвторизацииИБ");

КонецПроцедуры // Параметры_ИБ_ПолноеОписание()

// Процедура заполняет параметры команды добавления информационной базы
//
Процедура Параметры_ИБ_Добавить() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("create");
	
	ДобавитьПараметрПоШаблону("--name=%1"  , "Имя");
	ДобавитьПараметрПоШаблону("--locale=%1", "Локализация");
	
	Если ЗначениеФлага("СоздатьБазуСУБД") Тогда
		ДобавитьПараметрСтроку("--create-database");
	КонецЕсли;

	ПараметрыОбъекта = Новый ПараметрыОбъекта("infobase");
	ВсеПараметры = ПараметрыОбъекта.Получить();

	Для Каждого ТекЭлемент Из ВсеПараметры Цикл
		Если НЕ ТекЭлемент.Значение.Добавление Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ ЗначенияПараметров.Получить(ТекЭлемент.Ключ) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ДобавитьПараметрПоШаблону(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ТекЭлемент.Ключ);
	КонецЦикла;

КонецПроцедуры // Параметры_ИБ_Добавить()

// Процедура заполняет параметры команды изменения информационной базы
//
Процедура Параметры_ИБ_Изменить() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("update");

	ДобавитьПараметрПоШаблону("--infobase=%1", "ИдентификаторИБ");
	ДобавитьПараметрПоИмени("СтрокаАвторизацииИБ");

	ПараметрыОбъекта = Новый ПараметрыОбъекта("infobase");
	ВсеПараметры = ПараметрыОбъекта.Получить();

	Для Каждого ТекЭлемент Из ВсеПараметры Цикл
		Если НЕ ТекЭлемент.Значение.Добавление Тогда
			Продолжить;
		КонецЕсли;
		Если НЕ ЗначенияПараметров.Получить(ТекЭлемент.Ключ) = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		ДобавитьПараметрПоШаблону(ТекЭлемент.Значение.ПараметрКоманды + "=%1", ТекЭлемент.Ключ);
	КонецЦикла;

КонецПроцедуры // Параметры_ИБ_Изменить()

// Процедура заполняет параметры команды удаления информационной базы
//
Процедура Параметры_ИБ_Удалить() Экспорт

	Параметры_ИБ_Общие();

	ДобавитьПараметрСтроку("drop");

	ДобавитьПараметрПоШаблону("--infobase=%1", "ИдентификаторИБ");
	ДобавитьПараметрПоИмени("СтрокаАвторизацииИБ");

	Если ЗначенияПараметров.Получить("ДействияСБазойСУБД") = "drop" Тогда
		ДобавитьПараметрСтроку("--drop-database");
	ИначеЕсли ЗначенияПараметров.Получить("ДействияСБазойСУБД") = "clear" Тогда
		ДобавитьПараметрСтроку("--clear-database");
	КонецЕсли;

КонецПроцедуры // Параметры_ИБ_Удалить()

#КонецОбласти // ИнформационныеБазы

#КонецОбласти // ПроцедурыЗаполненияПараметровОбъектов

#Область СлужебныеПроцедуры

// Процедура заполняет структуру правил заполнения описаний свойств и команд объектов
//
Процедура ЗаполнитьПолучениеПараметровОбъекта()

	ОписанияОбъектов = Новый Соответствие();

	ОписанияОбъектов.Вставить("Кластер:cluster"                        , "Список:list, 
	                                                                     |Описание:info,
												                         |Добавить:insert,
												                         |Изменить:update,
												                         |Удалить:remove");
	
	ОписанияОбъектов.Вставить("Агент.Администратор:agent.admin"        , "Список:list, 
												                         |Добавить:register,
												                         |Удалить:remove");
	
	ОписанияОбъектов.Вставить("Кластер.Администратор:cluster.admin"    , "Список:list, 
												                         |Добавить:register,
												                         |Удалить:remove");
	
	ОписанияОбъектов.Вставить("МенеджерКластера:manager"               , "Список:list, 
	                                                                     |Описание:info");
	
	ОписанияОбъектов.Вставить("Сервис:service"                         , "Список:list");
	
	ОписанияОбъектов.Вставить("Сервер:server"                          , "Список:list, 
	                                                                     |Описание:info,
												                         |Добавить:insert,
												                         |Изменить:update,
												                         |Удалить:remove");
	
	ОписанияОбъектов.Вставить("РабочийПроцесс:process"                 , "Список:list, 
	                                                                     |Описание:info");
	
	ОписанияОбъектов.Вставить("РабочийПроцесс.Лицензия:process.license", "Список:list, 
	                                                                     |Описание:info");
	
	ОписанияОбъектов.Вставить("Сеанс:session"                          , "Список:list, 
	                                                                     |Описание:info,
	                                                                     |Удалить:terminate");
	
	ОписанияОбъектов.Вставить("Сеанс.Лицензия:session.license"         , "Список:list, 
	                                                                     |Описание:info");
	
	ОписанияОбъектов.Вставить("Соединение:connection"                  , "Список:list, 
	                                                                     |Описание:info,
	                                                                     |Удалить:disconnect");
	
	ОписанияОбъектов.Вставить("ИБ:infobase"                            , "Список:list, 
	                                                                     |Описание:summary,
											                             |ПолноеОписание:info,
											                             |Добавить:create,
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Блокировка:lock"                        , "Список:list");
	
	ОписанияОбъектов.Вставить("ТребованиеНазначения:rule"              , "Список:list, 
	                                                                     |Описание:info,
											                             |Добавить:insert,
											                             |Изменить:update,
											                             |Удалить:remove,
											                             |Применить:apply");

	ОписанияОбъектов.Вставить("Профиль:profile"                        , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.Каталог:profile.directory"      , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.COMКласс:profile.com"           , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.Компонент:profile.addin"        , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.Модуль:profile.module"          , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.Приложение:profile.app"         , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	ОписанияОбъектов.Вставить("Профиль.ИнтернетРесурс:profile.inet"    , "Список:list, 
											                             |Изменить:update,
											                             |Удалить:remove");

	Для Каждого ТекОписание Из ОписанияОбъектов Цикл
		ДобавитьПолучениеПараметровОбъекта(ТекОписание.Ключ, ТекОписание.Значение);
	КонецЦикла;

КонецПроцедуры // ЗаполнитьПолучениеПараметровОбъекта()

// Процедура добавляет правило заполнения описания свойств и команд объекта
//
Процедура ДобавитьПолучениеПараметровОбъекта(ИменаТипаОбъекта, ДоступныеКоманды)

	Если НЕ ТипЗнч(ПолучениеПараметровОбъектов) = Тип("Соответствие") Тогда
		ПолучениеПараметровОбъектов = Новый Соответствие();
	КонецЕсли;

	МассивИменТипов = СтрРазделить(ИменаТипаОбъекта, ":");

	ОсновноеИмяТипа = СокрЛП(МассивИменТипов[0]);
	ИмяПроцедуры = "Параметры_" + СтрЗаменить(ОсновноеИмяТипа, ".", "_") + "_Свойства"; 

	ПолучениеПараметровОбъекта = Новый Соответствие();
	ПолучениеПараметровОбъекта.Вставить("ИмяТипа", ОсновноеИмяТипа);
	ПолучениеПараметровОбъекта.Вставить("Параметры", ИмяПроцедуры);

	МассивКоманд = СтрРазделить(ДоступныеКоманды, ",");

	ПолучениеПараметровКоманд = Новый Соответствие();

	Для Каждого ТекИменаКоманды Из МассивКоманд Цикл
		МассивИменКоманды = СтрРазделить(СокрЛП(ТекИменаКоманды), ":");

		ОсновноеИмяКоманды = СокрЛП(МассивИменКоманды[0]);
		ИмяПроцедуры = "Параметры_" + СтрЗаменить(ОсновноеИмяТипа, ".", "_") + "_" + ОсновноеИмяКоманды;

		ПолучениеПараметровКоманды = Новый Соответствие();
		ПолучениеПараметровКоманды.Вставить("ИмяКоманды", ОсновноеИмяКоманды);
		ПолучениеПараметровКоманды.Вставить("Параметры", ИмяПроцедуры);

		Для Каждого ТекИмяКоманды Из МассивИменКоманды Цикл
			ПолучениеПараметровКоманд.Вставить(ВРег(СокрЛП(ТекИмяКоманды)), ПолучениеПараметровКоманды);
		КонецЦикла;
	КонецЦикла;

	ПолучениеПараметровОбъекта.Вставить("Команды", ПолучениеПараметровКоманд);

	Для Каждого ТекИмяТипа Из МассивИменТипов Цикл
		ПолучениеПараметровОбъектов.Вставить(ВРег(СокрЛП(ТекИмяТипа)), ПолучениеПараметровОбъекта);
	КонецЦикла;

КонецПроцедуры // ДобавитьПолучениеПараметровОбъекта()

// Процедура добавляет описание свойства в массив свойств
//   
// Параметры:
//   ИмяПараметра           - Строка                - имя свойства объекта
//   ИмяПоляРАК             - Строка                - имя свойства, как оно возвращается утилитой RAC
//   ЗначениеПоУмолчанию    - Произвольный          - значение свойства объекта по умолчанию
//   Использование          - Строка, Структура     - строка содержащая флаги использования, разделенные ","
//                                                    (Чтение, Добавление, Изменение)
//                                                    если указана структура, то в значении можно переопределить
//                                                    имя параметра утилиты RAC
//   
Процедура ДобавитьОписаниеСвойстваОбъекта(Знач ИмяПараметра
										, Знач ИмяПоляРАК
										, Знач ЗначениеПоУмолчанию = ""
										, Знач Использование = "Чтение")

	Если НЕ ТипЗнч(ОписаниеСвойств) = Тип("Массив") Тогда
		ОписаниеСвойств = Новый Массив();
	КонецЕсли;

	Если ТипЗнч(Использование) = Тип("Строка") Тогда
		Использование = Новый Структура(Использование);
	ИначеЕсли НЕ ТипЗнч(Использование) = Тип("Структура") Тогда
		Использование = Новый Структура();
	КонецЕсли;

	ОписаниеСвойства = Новый Структура();
	ОписаниеСвойства.Вставить("ИмяПараметра"        , ИмяПараметра);
	ОписаниеСвойства.Вставить("ИмяПоляРак"          , ИмяПоляРак);
	ОписаниеСвойства.Вставить("ПараметрКоманды"     , "");
	ОписаниеСвойства.Вставить("ЗначениеПоУмолчанию" , ЗначениеПоУмолчанию);
	ОписаниеСвойства.Вставить("Чтение"              , Использование.Свойство("Чтение"));
	ОписаниеСвойства.Вставить("Добавление"          , Использование.Свойство("Добавление"));
	ОписаниеСвойства.Вставить("Изменение"           , Использование.Свойство("Изменение"));

	Если Использование.Свойство("ПараметрКоманды") Тогда
		ОписаниеСвойства.ПараметрКоманды = Использование.ПараметрКоманды;
	ИначеЕсли ОписаниеСвойства.Добавление ИЛИ ОписаниеСвойства.Изменение Тогда
		ОписаниеСвойства.ПараметрКоманды = "--" + ОписаниеСвойства.ИмяПоляРАК;
	КонецЕсли;

	ОписаниеСвойств.Добавить(ОписаниеСвойства);

КонецПроцедуры // ДобавитьОписаниеСвойстваОбъекта()

// Процедура добавляет переданное значение в массив параметров запуска команды
//   
// Параметры:
//   Параметр		        - Строка            - добавляемое значение
//   Обязательный           - Булево            - Истина - если параметр не заполнен будет выдано исключение
//   ДобавлятьПустой        - Булево            - Истина - если параметр не заполнен будет добавлена пустая строка
//   
Процедура ДобавитьПараметрСтроку(Знач Параметр, Обязательный = Ложь, ДобавлятьПустой = Истина)

	Если НЕ ТипЗнч(ПараметрыЗапуска) = Тип("Массив") Тогда
		ПараметрыЗапуска = Новый Массив();
	КонецЕсли;
	
	Если НЕ ТипЗнч(Параметр) = Тип("Строка") Тогда
		Параметр = "";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Параметр) И Обязательный Тогда
		ВызватьИсключение "Не заполнен обязательный параметр!";
	КонецЕсли;

	Если ЗначениеЗаполнено(Параметр) ИЛИ ДобавлятьПустой Тогда
		ПараметрыЗапуска.Добавить(Параметр);
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрСтроку()

// Процедура добавляет значение параметра из структуры значений параметров в массив параметров запуска команды
//   
// Параметры:
//   ИмяПараметра	        - Строка            - имя параметра в структуре значений параметров
//   Обязательный           - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет выдано исключение
//   ДобавлятьПустой        - Булево            - Истина - если значение параметра не найдено
//                                                         или не заполнено будет добавлена пустая строка
//   
Процедура ДобавитьПараметрПоИмени(Знач ИмяПараметра, Обязательный = Ложь, ДобавлятьПустой = Истина)

	Если НЕ ТипЗнч(ПараметрыЗапуска) = Тип("Массив") Тогда
		ПараметрыЗапуска = Новый Массив();
	КонецЕсли;
	
	Параметр = ЗначенияПараметров.Получить(ИмяПараметра);
	Если Параметр = Неопределено Тогда
		Параметр = "";
	КонецЕсли;

	Если НЕ ЗначениеЗаполнено(Параметр) И Обязательный Тогда
		ВызватьИсключение СтрШаблон("Не заполнен обязательный параметр %1!", ИмяПараметра);
	КонецЕсли;

	Если ЗначениеЗаполнено(Параметр) ИЛИ ДобавлятьПустой Тогда
		ПараметрыЗапуска.Добавить(Параметр);
	КонецЕсли;

КонецПроцедуры // ДобавитьПараметрПоИмени()

// Процедура выполняет подстановку значения параметра из структуры значений параметров в шаблон
// и добавляет результат в массив параметров запуска команды
//   
// Параметры:
//   ШаблонПараметра        - Строка            - шаблон, в который будет выполнена подстановка
//   ИмяПараметра	        - Строка            - имя параметра в структуре значений параметров
//   
Процедура ДобавитьПараметрПоШаблону(Знач ШаблонПараметра, Знач ИмяПараметра)

	Если НЕ ТипЗнч(ПараметрыЗапуска) = Тип("Массив") Тогда
		ПараметрыЗапуска = Новый Массив();
	КонецЕсли;
	
	ЗначениеПараметра = ЗначенияПараметров.Получить(ИмяПараметра);

	Если НЕ ЗначениеЗаполнено(ЗначениеПараметра) Тогда
		ВызватьИсключение СтрШаблон("Не заполнен обязательный параметр %1!", ИмяПараметра);
	КонецЕсли;

	ПараметрыЗапуска.Добавить(СтрШаблон(ШаблонПараметра, ЗначениеПараметра));

КонецПроцедуры // ДобавитьПараметрПоШаблону()

// Функция возвращает значение параметра-флага из структуры значений параметров
//   
// Параметры:
//   ИмяПараметра	        - Строка            - имя параметра в структуре значений параметров
//   
// Возвращаемое значение:
//	Булево          - значение флага, если параметр отсутствует в структуре значений параметров,
//                    возвращается Ложь
//
Функция ЗначениеФлага(Знач ИмяПараметра)

	Параметр = ЗначенияПараметров.Получить(ИмяПараметра);
	Если Параметр = Неопределено Тогда
		Параметр = Ложь;
	КонецЕсли;

	Возврат Параметр;

КонецФункции // ЗначениеФлага()

#КонецОбласти // СлужебныеПроцедуры

Лог = Логирование.ПолучитьЛог("ktb.lib.irac");
