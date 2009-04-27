<?xml version="1.0" encoding="UTF-8"?><wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:apachesoap="http://xml.apache.org/xml-soap" xmlns:impl="http://global/api/authentication.cfc" xmlns:intf="http://global/api/authentication.cfc" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" targetNamespace="http://global/api/authentication.cfc">
  <wsdl:message name="loginResponse">
    <wsdl:part name="loginReturn" type="xsd:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="loginRequest">
    <wsdl:part name="hostid" type="xsd:double">
    </wsdl:part>
    <wsdl:part name="user" type="xsd:string">
    </wsdl:part>
    <wsdl:part name="pass" type="xsd:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:portType name="authentication">
    <wsdl:operation name="login" parameterOrder="hostid user pass">
      <wsdl:input message="impl:loginRequest" name="loginRequest">
    </wsdl:input>
      <wsdl:output message="impl:loginResponse" name="loginResponse">
    </wsdl:output>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="authentication.cfcSoapBinding" type="impl:authentication">
    <wsdlsoap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="login">
      <wsdlsoap:operation soapAction=""/>
      <wsdl:input name="loginRequest">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://api.global.na_svr" use="encoded"/>
      </wsdl:input>
      <wsdl:output name="loginResponse">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://global/api/authentication.cfc" use="encoded"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="authenticationService">
    <wsdl:port binding="impl:authentication.cfcSoapBinding" name="authentication.cfc">
      <wsdlsoap:address location="http://batchass.razuna.com/global/api/authentication.cfc"/>
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>