﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ОбновитьСписки();	
	
КонецПроцедуры

Процедура ОбновитьСписки()
	
	Выборка = ВыборкаЗадач(Справочники.СостоянияЗадач.Создана);
	Пока Выборка.Следующий() Цикл
		Создана.Добавить(Выборка.Задача);		
	КонецЦикла; 
	
	Выборка = ВыборкаЗадач(Справочники.СостоянияЗадач.НаПланировании);
	Пока Выборка.Следующий() Цикл
		НаПланировании.Добавить(Выборка.Задача);		
	КонецЦикла; 

	Выборка = ВыборкаЗадач(Справочники.СостоянияЗадач.Выполняется);
	Пока Выборка.Следующий() Цикл
		Выполняется.Добавить(Выборка.Задача);		
	КонецЦикла; 
	
	Выборка = ВыборкаЗадач(Справочники.СостоянияЗадач.НаКонтроле);
	Пока Выборка.Следующий() Цикл
		НаКонтроле.Добавить(Выборка.Задача);		
	КонецЦикла; 
	
	Выборка = ВыборкаЗадач(Справочники.СостоянияЗадач.Завершена);
	Пока Выборка.Следующий() Цикл
		Завершена.Добавить(Выборка.Задача);		
	КонецЦикла; 
	
КонецПроцедуры
 
&НаСервере
Функция ВыборкаЗадач(Состояние)
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	Задача.Ссылка КАК Ссылка,
		|	Задача.НаименованиеЗадачи КАК Задача
		|ИЗ
		|	Документ.Задача КАК Задача
		|ГДЕ
		|	Задача.Состояние = &Состояние
		|	И 1 = 1";
	
	Если ЗначениеЗаполнено(Объект.Проект) Тогда
		Запрос.Текст = СтрЗаменить(Запрос.Текст, "1 = 1", "Задача.ПроектГруппа = &ПроектГруппа");
		Запрос.УстановитьПараметр("ПроектГруппа", Объект.Проект);
	КонецЕсли; 
	Запрос.УстановитьПараметр("Состояние", Состояние);
	
	Рез = Запрос.Выполнить();
	Возврат Рез.Выбрать();
	
КонецФункции


&НаСервере
Процедура СозданаПеретаскиваниеНаСервере()

	с = 1;
	
КонецПроцедуры


&НаКлиенте
Процедура СозданаПеретаскивание(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СозданаПеретаскиваниеНаСервере();
	Элементы.Создана.Обновить(); 
	СтандартнаяОбработка = Ложь; 
КонецПроцедуры


&НаКлиенте
Процедура СозданаПроверкаПеретаскивания(Элемент, ПараметрыПеретаскивания, СтандартнаяОбработка, Строка, Поле)
	СтандартнаяОбработка = Ложь; 
КонецПроцедуры
 