package tn.chatboot;

import jakarta.jws.WebService;

@WebService(
    serviceName = "ChatService",
    portName = "ChatServicePort",
    targetNamespace = "http://tn.chatboot/soap",
    endpointInterface = "tn.chatboot.ChatService")
public class ChatServiceImpl implements ChatService {
  @Override
  public String sendMessage(String message) {
    return "SOAP echo: " + message;
  }

  @Override
  public String getConversationSummary(String conversationId) {
    return "Résumé de la conversation " + conversationId;
  }
}
