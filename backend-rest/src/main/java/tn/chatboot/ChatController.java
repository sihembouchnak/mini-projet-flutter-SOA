package tn.chatboot;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api")
@CrossOrigin
public class ChatController {
  private final ConversationRepository repository;

  public ChatController(ConversationRepository repository) {
    this.repository = repository;
  }

  @GetMapping("/health")
  public Map<String, Object> health() {
    return Map.of("status", "UP");
  }

  @PostMapping("/chat")
  public ResponseEntity<Map<String, String>> chat(
      @AuthenticationPrincipal Jwt jwt,
      @RequestBody Map<String, Object> request) {
    Object message = request.get("message");
    if (message == null || message.toString().trim().isEmpty()) {
      return ResponseEntity.badRequest().body(Map.of("error", "message is required"));
    }
    String reply = "Réponse du serveur Chatboot pour " + jwt.getSubject() +
        ": " + message;
    return ResponseEntity.ok(Map.of("reply", reply));
  }

  @GetMapping("/conversations")
  public List<Conversation> conversations(@AuthenticationPrincipal Jwt jwt) {
    return repository.findByUserIdOrderByUpdatedAtDesc(jwt.getSubject());
  }

  @PostMapping("/conversations")
  public ResponseEntity<Conversation> createConversation(
      @AuthenticationPrincipal Jwt jwt,
      @RequestBody Conversation conversation) {
    conversation.setId(null);
    conversation.setUserId(jwt.getSubject());
    if (conversation.getTitle() == null || conversation.getTitle().trim().isEmpty()) {
      conversation.setTitle("Nouvelle conversation");
    }
    if (conversation.getUpdatedAt() == null) conversation.setUpdatedAt(Instant.now());
    return ResponseEntity.status(HttpStatus.CREATED).body(repository.save(conversation));
  }

  @PutMapping("/conversations/{id}")
  public ResponseEntity<Conversation> updateConversation(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable String id,
      @RequestBody Conversation update) {
    return repository.findByIdAndUserId(id, jwt.getSubject())
        .map(existing -> {
          existing.setTitle(update.getTitle());
          existing.setMessages(update.getMessages());
          existing.setUpdatedAt(Instant.now());
          return ResponseEntity.ok(repository.save(existing));
        })
        .orElse(ResponseEntity.notFound().build());
  }

  @DeleteMapping("/conversations/{id}")
  public ResponseEntity<Void> deleteConversation(
      @AuthenticationPrincipal Jwt jwt,
      @PathVariable String id) {
    if (repository.findByIdAndUserId(id, jwt.getSubject()).isEmpty()) {
      return ResponseEntity.notFound().build();
    }
    repository.deleteByIdAndUserId(id, jwt.getSubject());
    return ResponseEntity.noContent().build();
  }
}
