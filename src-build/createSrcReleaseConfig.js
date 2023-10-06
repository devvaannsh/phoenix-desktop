import {fileURLToPath} from "url";
import {dirname} from "path";
import fs from 'fs';

import {getPlatformDetails} from "./utils.js";
import chalk from "chalk";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

async function createSrcReleaseConfig() {
    const platform = getPlatformDetails().platform;
    const tauriConfigPath = (platform === "win") ? `${__dirname}\\..\\src-tauri\\tauri.conf.json`
        : `${__dirname}/../src-tauri/tauri.conf.json`;
    const tauriLocalConfigPath = (platform === "win") ? `${__dirname}\\..\\src-tauri\\tauri-local.conf.json`
        : `${__dirname}/../src-tauri/tauri-local.conf.json`;
    console.log("Reading config file: ", tauriConfigPath);
    let configJson = JSON.parse(fs.readFileSync(tauriConfigPath));
    console.log(chalk.magenta("\n!Only creating executables. Creating msi, appimage and dmg installers are disabled in this build. If you want to create an installer, use: npm run tauri build manually after setting distDir in tauri conf!\n"));
    configJson.tauri.bundle.active = false;
    configJson.build.distDir = '../../phoenix/src/'
    console.log("Writing new local config json ", tauriLocalConfigPath);
    fs.writeFileSync(tauriLocalConfigPath, JSON.stringify(configJson, null, 4));
}

await createSrcReleaseConfig();
