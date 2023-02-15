use axum::{
    http::StatusCode,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};

#[tokio::main(flavor = "current_thread")]
async fn main() -> anyhow::Result<()> {
    // initialize tracing
    tracing_subscriber::fmt::init();

    // build our application with a route
    let app = Router::new()
        // `GET /` goes to `root`
        .route("/", get(root))
        // `POST /users` goes to `create_user`
        .route("/users", post(create_user));

    #[cfg(not(target_arch = "wasm32"))]
    {
        use std::net::SocketAddr;

        let addr = SocketAddr::from(([127, 0, 0, 1], 8080));
        tracing::debug!("listening on {}", addr);
        axum::Server::bind(&addr)
            .serve(app.into_make_service())
            .await?;
    }

    #[cfg(target_arch = "wasm32")]
    {
        use std::os::wasi::io::FromRawFd;

        tracing_subscriber::fmt::init();
        let std_listener = unsafe { std::net::TcpListener::from_raw_fd(3) };
        std_listener.set_nonblocking(true).unwrap();
        axum::Server::from_tcp(std_listener)
            .unwrap()
            .serve(app.into_make_service())
            .await?;
    }

    Ok(())
}

// basic handler that responds with a static string
async fn root() -> &'static str {
    "Try POSTing data to /users such as: `curl localhost:8080/users -XPOST -H 'Content-Type: application/json' -d '{ \"username\": \"foo\" }'`"
}

async fn create_user(
    // this argument tells axum to parse the request body
    // as JSON into a `CreateUser` type
    Json(payload): Json<CreateUser>,
) -> (StatusCode, Json<User>) {
    // insert your application logic here
    let user = User {
        id: 1337,
        username: payload.username,
    };

    // this will be converted into a JSON response
    // with a status code of `201 Created`
    (StatusCode::CREATED, Json(user))
}

// the input to our `create_user` handler
#[derive(Deserialize)]
struct CreateUser {
    username: String,
}

// the output to our `create_user` handler
#[derive(Serialize)]
struct User {
    id: u64,
    username: String,
}
