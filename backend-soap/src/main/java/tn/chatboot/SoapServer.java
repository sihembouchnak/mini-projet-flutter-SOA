package tn.chatboot;

import jakarta.xml.ws.Endpoint;

public class SoapServer {
  public static void main(String[] args) {
    String url = args.length > 0 ? args[0] : "http://localhost:8181/chat";
    Endpoint.publish(url, new ChatServiceImpl());
    System.out.println("SOAP service published at " + url + "?wsdl");
  }
}
