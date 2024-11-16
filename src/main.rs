use anyhow::{Context, Result};
use clap::Parser;
use itertools::Itertools;
use modrinth::fetch_project_file;
use std::env;
use std::io::Write;

mod modrinth;

/// Basic program that generates list of plugin versions that can be used with nix-minecraft
#[derive(Parser, Debug)]
#[command(author, version, about)]
struct Args {
    /// Loader type, examples: paper, fabric, bukkit
    #[arg(short, long, required = true, default_value_t = String::from("paper"))]
    loader: String,

    /// Game version, example: 1.21.1
    #[arg(short, long, required = true)]
    game_version: String,

    /// Project IDs, either id or slug from the website
    #[arg(short, long, required = true)]
    project: Vec<String>,

    /// Include all versions, by default only release versions are fetched
    #[arg(long, default_value_t = false)]
    all_versions: bool,

    /// File to write output to
    #[arg(short, long)]
    file: Option<String>,
}

#[tokio::main]
async fn main() -> Result<()> {
    let args = Args::parse();

    let mut plugins = Vec::new();
    for project in &args.project {
        let file = fetch_project_file(
            project.to_string(),
            &args.loader,
            &args.game_version,
            args.all_versions,
        )
        .await
        .context("Failed to fetch project file")?;
        plugins.push(format!("{file}"));
    }

    let cli_args = env::args().skip(1).join(" ");
    let plugin_lines = plugins.join("\n");

    let output = format!(
        r#"# auto generated with nix-minecraft-plugin-upgrade {cli_args}
{{ pkgs, ... }}: {{
{plugin_lines}
}}
"#
    );

    match args.file {
        Some(file) => std::fs::write(file, output).context("Failed to write file")?,
        _ => std::io::stdout().write_all(output.as_bytes())?,
    }

    Ok(())
}
