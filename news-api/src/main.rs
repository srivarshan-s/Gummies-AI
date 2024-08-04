use dotenv::dotenv;
use reqwest::Client;
use std::collections::HashMap;
use std::env;
use tokio;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = Client::new();

    dotenv().ok();
    let api_key = env::var("NEWS_API")?;

    let mut params = HashMap::new();
    params.insert("q", "Apple");
    params.insert("sortBy", "popularity");
    params.insert("apiKey", &api_key);

    let res = client
        .get("https://newsapi.org/v2/everything")
        .header("User-Agent", "news-api/0.1.0")
        .query(&params)
        .send()
        .await?;

    let body = res.text().await?;
    println!("{}", body);

    Ok(())
}
