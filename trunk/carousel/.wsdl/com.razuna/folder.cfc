<?xml version="1.0" encoding="UTF-8"?><wsdl:definitions xmlns:wsdl="http://schemas.xmlsoap.org/wsdl/" xmlns:apachesoap="http://xml.apache.org/xml-soap" xmlns:impl="http://global/api/folder.cfc" xmlns:intf="http://global/api/folder.cfc" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:wsdlsoap="http://schemas.xmlsoap.org/wsdl/soap/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" targetNamespace="http://global/api/folder.cfc">
  <wsdl:message name="getassetsRequest">
    <wsdl:part name="sessiontoken" type="xsd:string">
    </wsdl:part>
    <wsdl:part name="folderid" type="xsd:double">
    </wsdl:part>
    <wsdl:part name="showsubfolders" type="xsd:double">
    </wsdl:part>
    <wsdl:part name="offset" type="xsd:double">
    </wsdl:part>
    <wsdl:part name="maxrows" type="xsd:double">
    </wsdl:part>
    <wsdl:part name="show" type="xsd:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getassetsResponse">
    <wsdl:part name="getassetsReturn" type="xsd:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getfoldersRequest">
    <wsdl:part name="sessiontoken" type="xsd:string">
    </wsdl:part>
    <wsdl:part name="folderid" type="xsd:double">
    </wsdl:part>
  </wsdl:message>
  <wsdl:message name="getfoldersResponse">
    <wsdl:part name="getfoldersReturn" type="xsd:string">
    </wsdl:part>
  </wsdl:message>
  <wsdl:portType name="folder">
    <wsdl:operation name="getassets" parameterOrder="sessiontoken folderid showsubfolders offset maxrows show">
      <wsdl:input message="impl:getassetsRequest" name="getassetsRequest">
    </wsdl:input>
      <wsdl:output message="impl:getassetsResponse" name="getassetsResponse">
    </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getfolders" parameterOrder="sessiontoken folderid">
      <wsdl:input message="impl:getfoldersRequest" name="getfoldersRequest">
    </wsdl:input>
      <wsdl:output message="impl:getfoldersResponse" name="getfoldersResponse">
    </wsdl:output>
    </wsdl:operation>
  </wsdl:portType>
  <wsdl:binding name="folder.cfcSoapBinding" type="impl:folder">
    <wsdlsoap:binding style="rpc" transport="http://schemas.xmlsoap.org/soap/http"/>
    <wsdl:operation name="getassets">
      <wsdlsoap:operation soapAction=""/>
      <wsdl:input name="getassetsRequest">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://api.global.na_svr" use="encoded"/>
      </wsdl:input>
      <wsdl:output name="getassetsResponse">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://global/api/folder.cfc" use="encoded"/>
      </wsdl:output>
    </wsdl:operation>
    <wsdl:operation name="getfolders">
      <wsdlsoap:operation soapAction=""/>
      <wsdl:input name="getfoldersRequest">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://api.global.na_svr" use="encoded"/>
      </wsdl:input>
      <wsdl:output name="getfoldersResponse">
        <wsdlsoap:body encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" namespace="http://global/api/folder.cfc" use="encoded"/>
      </wsdl:output>
    </wsdl:operation>
  </wsdl:binding>
  <wsdl:service name="folderService">
    <wsdl:port binding="impl:folder.cfcSoapBinding" name="folder.cfc">
      <wsdlsoap:address location="http://api.razuna.com/global/api/folder.cfc"/>
    </wsdl:port>
  </wsdl:service>
</wsdl:definitions>