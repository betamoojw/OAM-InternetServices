## **Änderungshistorie**

20.04.2024 Internet Services 1.0

* Initiales Release


## **Einleitung**

<!-- DOC -->
## **Internet Services Application**

Auf dieser Seite erfolgen die grundsätzlichen Einstellungen für die Applikation. 

Unter Kanalauswahl können die verfügbaren Kommunikationsobjekte ausgewählt werden und unter Editieroptionen die möglichen Editoren der Applikation.

<!-- DOC -->
### **Anzahl der Kommunikationsobjekte**

Um die Applikation übersichtlicher zu gestalten, kann hier ausgewählt werden, wie viele Kommunikationsobjekte in der Applikation verfügbar und editierbar sind. Die Maximalanzahl der Kanäle hängt von der Applikationsvariante ab, die gerade verwendet wird und wird angezeigt.

Die ETS ist auch schneller in der Anzeige, wenn sie weniger (leere) Kommunikationsobjekte darstellen muss. Insofern macht es Sinn, nur so viele Kommunikationsobjekte anzuzeigen, wie man wirklich braucht.

<!-- DOC -->
### **Editiermodus**

Man kann die Kommunikationsobjekte in zwei unterschiedlichen Modi editieren. In diesem Auswahlfeld kann man den Editiermodus ausblenden, den Sie nicht benötigen, um damit die Applikation übersichtlicher zu gestalten.

#### **Übersicht und Detail**

Das ist der Standardwert und erlaubt es, die Kommunikationsobjekte in beiden Modi zu editieren.

#### **Nur Übersicht**

Wird dieser Modus gewählt, erscheint eine Seite mit allen Kommunikationsobjekten in einer Tabelle, mit allen Eigenschaften eines Kommunikationsobjekts pro Zeile.

Dieser Modus bietet eine gute Übersicht, erlaubt es aber nur jede Zelle der Tabelle einzeln zu ändern.

#### **Nur Details**

Wird dieser Modus gewählt, erscheint eine Seite für jedes zu editierende Kommunikationsobjekt mit allen seinen Eigenschaften auf der Seite.

Dieser Modus bietet unterstützt die ETS-Multiselect-Möglichkeiten, die es erlauben, viele gleichartige UI-Elemente zu selektieren und für alle diese Elemente mit einem Click eine Einstellung vorzunehmen.

Besonders für die Auswahl von Länge und vom Ein-/Ausgang ist dieser Modus wesentlich komfortabler.

<!-- DOC -->
## Übersicht

<!-- DOC Skip="1" -->
Diese Seiten erscheinen nur, wenn man bei [Editiermodus](#editiermodus) den Wert "Übersicht und Detail" oder "Nur Übersicht" gewählt hat.

Es erscheint eine Tabelle aller Kommunikationsobjekte und deren Eigenschaften, pro Zeile ein Kommunikationsobjekt.

Diese Darstellung ist übersichtlich, erlaubt aber nur Änderungen einzelner Tabellenzellen.


<!-- DOC -->
## **KO *n***

<!-- DOC Skip="1" -->
Diese Seiten erscheinen nur, wenn man bei [Editiermodus](#editiermodus) den Wert "Übersicht und Detail" oder "Nur Detail" gewählt hat.

Es erscheint für jedes Kommunikationsobjekt eine Seite mit allen Eigenschaften dieses Kommunikationsobjekts. 

Diese Darstellung unterstützt das ETS-Multiselect. Man kann mehrere gleichartige Objekte markieren und mit einem Click die Eigenschaften aller markierten Objekte ändern. 

Dies bietet sich besonders für die Eigenschaften Länge und Ein-/Ausgang an.

<!-- DOC -->
### **Name des KO**

Hier wird der Name für das Kommunikationsobjekt vergeben. Er ist frei wählbar und kann bis zu 40 Zeichen lang sein.

<!-- DOC -->
### **Ein-/Ausgang**

Hier wird festgelegt, ob das Kommunikationsobjekt einen Ein- oder einen Ausgang repräsentiert oder beides. Dabei wird das immer aus der Sicht des Gerätes betrachtet, das durch den Dummy repräsentiert wird. Eingang bedeutet also, dass das Gerät Telegramme vom KNX-Bus empfängt, Ausgang dass es Telegramme auf den KNX-Bus sendet.

<!-- DOC -->
### **Länge des KO**

Hier wird die Länge des Kommunikationsobjektes festgelegt (Wichtig: Nicht der DPT). Eine richtige Länge vorausgesetzt ist es dann in einem 2. Schritt möglich, dieses KO mit Gruppenadressen zu verknüpfen und einen passenden DPT zuzuweisen.

<!-- DOC HelpContext="OpenKNX" -->
## Das OpenKNX-Projekt

OpenKNX ist eine offene Gemeinschaft von Hobbyisten die freie und quelloffene Software für KNX-Geräte erstellen. Um eine nachhaltige und professionelle Integration ins Smarthome zu erreichen streben wir eine weitgehende Kompatibilität zum KNX-Standard an. Mit OpenKNX hast Du die Möglichkeit bereits fertige Lösungen einzusetzen, diese individuell anzupassen oder ganz neue Lösungen zu realisieren - der modulare Ansatz bietet schnelle Erfolge durch den Einsatz bewährter Softwaremodule.

Weitere Informationen findest Du unter: www.openknx.de - wiki.openknx.de - forum.openknx.de