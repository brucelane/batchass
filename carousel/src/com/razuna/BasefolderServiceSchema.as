package com.razuna
{
	 import mx.rpc.xml.Schema
	 public class BasefolderServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BasefolderServiceSchema():void
		{
			 var xsdXML0:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:axis2wrapped="http://api.global.na_svr" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://api.global.na_svr">
    <xsd:element name="getassets">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="sessiontoken" type="xsd:string"/>
                <xsd:element form="unqualified" name="folderid" type="xsd:double"/>
                <xsd:element form="unqualified" name="showsubfolders" type="xsd:double"/>
                <xsd:element form="unqualified" name="offset" type="xsd:double"/>
                <xsd:element form="unqualified" name="maxrows" type="xsd:double"/>
                <xsd:element form="unqualified" name="show" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="getfolders">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="sessiontoken" type="xsd:string"/>
                <xsd:element form="unqualified" name="folderid" type="xsd:double"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://api.global.na_svr'));
			 var xsdXML1:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:axis2wrapped="http://global/api/folder.cfc" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://global/api/folder.cfc">
    <xsd:element name="getassetsResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="getassetsReturn" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
    <xsd:element name="getfoldersResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="getfoldersReturn" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
;
			 var xsdSchema1:Schema = new Schema(xsdXML1);
			schemas.push(xsdSchema1);
			targetNamespaces.push(new Namespace('','http://global/api/folder.cfc'));
		}
	}
}