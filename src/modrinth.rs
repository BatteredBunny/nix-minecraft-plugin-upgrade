use std::fmt;

use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct FileHashes {
    pub sha512: String,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct ProjectFile {
    pub filename: String,
    pub url: String,
    pub hashes: FileHashes,
}

impl fmt::Display for ProjectFile {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "  \"plugins/{}\" = pkgs.fetchurl {{ url = \"{}\"; sha512 = \"{}\"; }};",
            self.filename, self.url, self.hashes.sha512
        )
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct ProjectVersion {
    pub files: Vec<ProjectFile>,
    pub version_type: String,
}

pub async fn fetch_project_file(
    project: String,
    loader: &str,
    game_version: &str,
    all_versions: bool,
) -> Result<ProjectFile> {
    let url = format!(
        "https://api.modrinth.com/v2/project/{project}/version?loaders=[\"{loader}\"]&game_versions=[\"{game_version}\"]",
    );

    reqwest::get(&url)
        .await
        .context("Failed to fetch from Modrinth API")?
        .error_for_status()?
        .json::<Vec<ProjectVersion>>()
        .await
        .context("Failed to parse response from Modrinth API")?
        .iter()
        .find(|version| match all_versions {
            true => true,
            false => version.version_type == "release", // Finds first versions thats type of "release"
        })
        .context("No matching versions found")?
        .files
        .first()
        .cloned()
        .context("No version file found")
}
