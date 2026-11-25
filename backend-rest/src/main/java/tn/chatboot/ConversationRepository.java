package tn.chatboot;

import org.springframework.data.mongodb.repository.MongoRepository;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends MongoRepository<Conversation, String> {
  List<Conversation> findByUserIdOrderByUpdatedAtDesc(String userId);
  Optional<Conversation> findByIdAndUserId(String id, String userId);
  void deleteByIdAndUserId(String id, String userId);
}
