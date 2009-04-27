package com.razuna
{
	 import mx.rpc.xml.Schema
	 public class BaseauthenticationServiceSchema
	{
		 public var schemas:Array = new Array();
		 public var targetNamespaces:Array = new Array();
		 public function BaseauthenticationServiceSchema():void
		{
			 var xsdXML0:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:axis2wrapped="http://api.global.na_svr" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://api.global.na_svr">
    <xsd:element name="login">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="hostid" type="xsd:double"/>
                <xsd:element form="unqualified" name="user" type="xsd:string"/>
                <xsd:element form="unqualified" name="pass" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
;
			 var xsdSchema0:Schema = new Schema(xsdXML0);
			schemas.push(xsdSchema0);
			targetNamespaces.push(new Namespace('','http://api.global.na_svr'));
			 var xsdXML1:XML = <xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:axis2wrapped="http://global/api/authentication.cfc" attributeFormDefault="unqualified" elementFormDefault="unqualified" targetNamespace="http://global/api/authentication.cfc">
    <xsd:element name="loginResponse">
        <xsd:complexType>
            <xsd:sequence>
                <xsd:element form="unqualified" name="loginReturn" type="xsd:string"/>
            </xsd:sequence>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
;
			 var xsdSchema1:Schema = new Schema(xsdXML1);
			schemas.push(xsdSchema1);
			targetNamespaces.push(new Namespace('','http://global/api/authentication.cfc'));
		}
	}
}