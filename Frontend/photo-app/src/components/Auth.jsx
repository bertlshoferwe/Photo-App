import { Authenticator } from "@aws-amplify/ui-react";
import "@aws-amplify/ui-react/styles.css";

export default function Auth({ children }) {
  return (
    <Authenticator>
      {({ signOut, user }) => (
        <div>
          <h2>Welcome, {user?.username}</h2>
          <button onClick={signOut}>Sign Out</button>
          {children}
        </div>
      )}
    </Authenticator>
  );
}