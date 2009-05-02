/*Classe Statique de chargement et gestion du XML */

package flashcomps {
	
	import flash.events.Event
	import flash.net.URLLoader
	import flash.net.URLRequest
	
	public final class XMLManager {
		
		public static var dataXML:XML; //XML dans lequel va être stocké le XML chargé
		public static var loader:URLLoader; //Loader qui va charger le XML
		
		/*-- Fonctions de chargement des données --*/
		
		//Fonction de chargement du XML de base
		public static function load(url:String):void {
			loader = new URLLoader(new URLRequest(url));			//création du loader et chargement des données
			loader.addEventListener(Event.COMPLETE, loadComplete);	//déclenché à la fin du chargement du XML
		}
		
		//Fonction déclenchée à la fin du chargement du XML
		private static function loadComplete(evt:Event):void {
			dataXML = new XML(evt.currentTarget.data);				//Stocke le XML chargé dans le XML prévu à cet effet
		}
		
		/*-- Fonctions publiques de configuration --*/
		
		//fonction renvoyant le radius du cercle
		public static function get radius():int {
			return dataXML.config.rotate.@rad
		}
		
		//fonction renvoyant l'indice de luminosité des images
		public static function get dark():int {
			return dataXML.config.rotate.@dark
		}
		
		
		//fonction renvoyant la taille max des miniatures
		public static function get thumbSize():Object {
			return {w:int(dataXML.config.thumb.@wMax), h:int(dataXML.config.thumb.@hMax)}
		}
		
		//fonction renvoyant le type d'affichage des images en plein écran
		public static function get viewType():String {
			return dataXML.config.view.@type
		}
		
		//fonction renvoyant le mode d'affichage des miniatures
		public static function get thumbType():String {
			return dataXML.config.view.@thumb
		}
		
		/*-- Fonctions Publiques de Données d'images--*/
		
		//fonction renvoyant le nombre d'images contenu dans le XML
		public static function get imgs():int {
			return dataXML.images.img.length();
		}
		
		//fonction renvoyant le chemin des images
		public static function get path():String {
			return dataXML.images.@path
		}
		
		//fonction renvoyant l'url complète (path+url) de l'image
		public static function getURL(nb:int):String {
			return path + dataXML.images.img[nb].@url
		}
		
	}
}