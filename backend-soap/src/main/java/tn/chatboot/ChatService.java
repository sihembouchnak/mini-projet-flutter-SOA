package tn.chatboot;

import jakarta.jws.WebMethod;
import jakarta.jws.WebService;

@WebService(name = "ChatService", targetNamespace = "http://tn.chatboot/soap")
public interface ChatService {
  @WebMethod
  String sendMessage(String message);

  @WebMethod
  String getConversationSummary(String conversationId);
}
