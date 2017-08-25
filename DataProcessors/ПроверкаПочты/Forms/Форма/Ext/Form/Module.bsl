﻿
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	Профиль = Новый ИнтернетПочтовыйПрофиль;
	
	ОсновнойПрофиль = НайтиОсновнойПрофильIMAP();
	
	Если ОсновнойПрофиль <> Неопределено Тогда
		
		Профиль.ИспользоватьSSLIMAP = ОсновнойПрофиль.ИспользоватьSSLIMAP;
		Профиль.АдресСервераIMAP 	= ОсновнойПрофиль.АдресСервераIMAP;
		Профиль.ПортIMAP 			= ОсновнойПрофиль.ПортIMAP; 	
		Профиль.ПользовательIMAP 	= ОсновнойПрофиль.ПользовательIMAP;
		Профиль.ПарольIMAP 			= ОсновнойПрофиль.ПарольIMAP;
		Профиль.ТолькоЗащищеннаяАутентификацияIMAP = ОсновнойПрофиль.ТолькоЗащищеннаяАутентификацияIMAP;
		
	Иначе
		
		Отказ = Истина;
		
	КонецЕсли; 
	
	Почта = Новый ИнтернетПочта;
	Сообщ = Новый СообщениеПользователю();
	
	Попытка
		Почта.Подключиться(Профиль, ПротоколИнтернетПочты.IMAP);		
		// Получаем все сообщения из почтового ящика
		МассивСообщений = Новый Массив;
		МассивСообщений = Почта.Выбрать(Ложь);
	Исключение
		// Ошибка при подключении к серверу или при приеме сообщения обмена
		Сообщ.Текст = " - Ошибка при подключении или приеме" + ОписаниеОшибки();
		Сообщ.Сообщить();
		Возврат;
	КонецПопытки;
	
	// Массив будет содержать сообщения, которые в последствии будут удалены с сервера 
	МассивСообщенийОбмена = Новый Массив;
	Если МассивСообщений.Количество() = 0 Тогда
		// Сообщений в почтовом ящике нет
		Сообщ.Текст = "Сообщений в почтовом ящике нет.";
		Сообщ.Сообщить();
		Возврат;
	КонецЕсли;
	
	ИмяФайлаСообщения = "";
	Для Индекс = 0 По МассивСообщений.Количество() - 1 Цикл  
		ЕстьТакаяЗадача = НайтиЗадачуПоИд(МассивСообщений[Индекс].ИдентификаторСообщения);
		Если ЕстьТакаяЗадача = Неопределено Тогда
			Структ = Новый Структура;
			Структ.Вставить("ИдентификаторСообщения", МассивСообщений[Индекс].ИдентификаторСообщения);
			Структ.Вставить("Тема", МассивСообщений[Индекс].Тема);
			Структ.Вставить("Текст", МассивСообщений[Индекс].Тексты[0].Текст);
			Структ.Вставить("Отправитель", МассивСообщений[Индекс].Отправитель.Адрес);
			ТС = СоздатьЗадачу(Структ);
		КонецЕсли; 
		//Попытка
		//	// Записываем файл 
		//	МассивСообщений[Индекс].Вложения[0].Данные.Записать(ПутьСохранения+"\"+МассивСообщений[Индекс].Вложения[0].ИмяФайла);
		//	Сообщ.Текст = "Принят файл: " + МассивСообщений[Индекс].Вложения[0].ИмяФайла + " с адреса " + Профиль.Пользователь;
		//	Сообщ.Сообщить(); 				
		//Исключение
		//	Сообщ.Текст = "Похоже нет файла в письме ) ";
		//	Сообщ.Сообщить(); 				
		//КонецПопытки;
	КонецЦикла;
	
	Почта.Отключиться(); 
	ЭтаФорма.Закрыть();
	
КонецПроцедуры

&НаСервере
Функция СоздатьЗадачу(Структ)
	
	СпрЗадача = Справочники.Задача.СоздатьЭлемент();
	СпрЗадача.ДатаСоздания = ТекущаяДата();
	СпрЗадача.ДатаИзменения = ТекущаяДата();
	СпрЗадача.ИдЗадачи = СокрЛП(Структ.ИдентификаторСообщения);
	СпрЗадача.Состояние = Справочники.СостоянияЗадач.Создана;
	СпрЗадача.Наименование = Структ.Тема;
	СпрЗадача.ОписаниеЗадачи = Новый ХранилищеЗначения(Структ.Текст);
	СпрЗадача.ПостановщикЗадачи = Справочники.Пользователи.Почта;
	СпрЗадача.Заказчик = НайтиКонтакт(Структ.Отправитель, "email");
	СпрЗадача.ПроектГруппа = НайтиГруппуКонтакта(СпрЗадача.Заказчик);
	
	Попытка
		СпрЗадача.Записать();
		Рет = "Задача " + СпрЗадача + " создана!";
	Исключение
		Рет = "Ошибка записи задачи: " + ОписаниеОшибки();
	КонецПопытки; 
	
	Возврат Рет;
	
КонецФункции

&НаСервере
Функция НайтиЗадачуПоИд(ИдЗадачи)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Задача.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Задача КАК Задача
		|ГДЕ
		|	Задача.ИдЗадачи = &ИдЗадачи";
	
	Запрос.УстановитьПараметр("ИдЗадачи", СокрЛП(ИдЗадачи));
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	Иначе
		Возврат Неопределено;
	КонецЕсли; 	
	
КонецФункции
 
&НаСервере
Функция НайтиКонтакт(ЧтоИскать, Тип = "email")
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Контакты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Контакты КАК Контакты
		|ГДЕ
		|	(Контакты.ЭлПочта = &ЧтоИскать)
		|	И НЕ Контакты.ПометкаУдаления";
	
	Запрос.УстановитьПараметр("ЧтоИскать", ЧтоИскать);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции
 
&НаСервере
Функция НайтиГруппуКонтакта(Конт)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПроектыКонтакты.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Проекты.Контакты КАК ПроектыКонтакты
		|ГДЕ
		|	ПроектыКонтакты.Контакт = &Конт";
	
	Запрос.УстановитьПараметр("Конт", Конт);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Если ВыборкаДетальныеЗаписи.Следующий() Тогда
		Возврат ВыборкаДетальныеЗаписи.Ссылка;
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

&НаСервере
Функция НайтиОсновнойПрофильIMAP()
	
	Если ЗначениеЗаполнено(ПараметрыСеанса.ТекущийПользователь.ПочтовыйПрофиль) Тогда
		Возврат ПараметрыСеанса.ТекущийПользователь.ПочтовыйПрофиль;
	Иначе
		Возврат Неопределено;
	КонецЕсли; 
	
КонецФункции
 
