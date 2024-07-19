import Principal "mo:base/Principal";
import TrieMap "mo:base/TrieMap";
import Iter "mo:base/Iter";

actor {
  // ---- types ----
  type User = {
    principal : Principal;
    username : Text;
    email : Text;
  };

  // ---- vars ----
  let users = TrieMap.TrieMap<Principal, User>(Principal.equal, Principal.hash);

  // ---- stable vars
  stable var stableUsers : [(Principal, User)] = [];

  // ---- shared methods ----
  public shared ({ caller }) func createUser(username : Text, email : Text) : async User {
    let user : User = {
      principal = caller;
      username;
      email;
    };

    users.put(caller, user);

    return user;
  };

  public shared ({ caller }) func deleteUser() : async ?User {
    return users.remove(caller);
  };

  // ---- query methods ----
  public query /* ({caller}) */ func getUser(principal : Principal) : async ?User {
    return users.get(principal);
  };

  // ---- system methods ----
  system func preupgrade() {
    stableUsers := Iter.toArray(users.entries());
  };

  system func postupgrade() {
    for ((principal, user) in stableUsers.vals()) {
      users.put(principal, user);
    };
  };

};
