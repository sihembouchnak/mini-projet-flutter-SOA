package tn.chatboot;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Document(collection = "boot")
public class Conversation {
  @Id
  private String id;
  @Indexed
  private String userId;
  private String title;
  private Instant updatedAt;
  private List<Message> messages = new ArrayList<>();

  public Conversation() {}

  public String getId() { return id; }
  public void setId(String id) { this.id = id; }
  public String getUserId() { return userId; }
  public void setUserId(String userId) { this.userId = userId; }
  public String getTitle() { return title; }
  public void setTitle(String title) { this.title = title; }
  public Instant getUpdatedAt() { return updatedAt; }
  public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
  public List<Message> getMessages() { return messages; }
  public void setMessages(List<Message> messages) { this.messages = messages; }

  public static class Message {
    private String role;
    private String content;
    private Instant createdAt;
    public Message() {}
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Instant getCreatedAt() { return createdAt; }
    public void setCreatedAt(Instant createdAt) { this.createdAt = createdAt; }
  }
}
