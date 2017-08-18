﻿
Процедура УстановкаПараметровСеанса(ТребуемыеПараметры)
	
	ТекПольз = Справочники.Пользователи.НайтиПоНаименованию(ИмяПользователя(), Истина);
	Если ТекПольз = Справочники.Пользователи.ПустаяСсылка() Тогда
		НовЭл = Справочники.Пользователи.СоздатьЭлемент();
		НовЭл.Наименование = ИмяПользователя();
		НовЭл.Записать();
		ТекПольз = НовЭл.Ссылка;
	КонецЕсли; 
	ПараметрыСеанса.ТекущийПользователь = ТекПольз;
	ПараметрыСеанса.ТекущийПроект = Справочники.Проекты.ПустаяСсылка();
	
КонецПроцедуры
