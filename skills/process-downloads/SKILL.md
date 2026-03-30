---
name: process-downloads
version: 1.0.0
description: |
  Process downloaded media files from /Volumes/complete folders. Extracts RAR
  archives and moves files to the correct location in /Volumes/media. Handles
  TV series (organized by show and season) and movies.
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
  - AskUserQuestion
  - TodoWrite
---

# Process Downloads Skill

Process media downloads from `/Volumes/complete` and organize them into `/Volumes/media`.

## Source Folders

- `/Volumes/complete/Series` - TV show episodes (RAR archives)
- `/Volumes/complete/Movies` - Movies (MKV files or RAR archives)

## Destination Folders

- `/Volumes/media/Video/TV` - TV shows organized as `{Show Name}/Season {XX}/`
- `/Volumes/media/Video/Movies` - Movies as standalone files

## Workflow

### 1. Scan Source Folders

Check what's available to process:

```bash
ls -la /Volumes/complete/Series/
ls -la /Volumes/complete/Movies/
```

Skip `.DS_Store` and `#recycle` folders.

### 2. Parse Media Information

**TV Series naming convention:** `Show.Name.SXXEXX.Quality.Source.Codec-GROUP`

Examples:
- `Doc.2025.S02E15.720p.HDTV.x264-SYNCOPY` → Show: "Doc", Year: 2025, Season: 02, Episode: 15
- `The.Beauty.S01E06.1080p.WEB.h264-ETHEL` → Show: "The Beauty", Season: 01, Episode: 06
- `The.Traitors.2023.S04E09.1080p.WEB.h264-EDITH` → Show: "The Traitors", Year: 2023, Season: 04, Episode: 09

**Movie naming convention:** `Movie.Name.Year.Quality.Source.Codec-GROUP`

Examples:
- `Spy.Kids.2.Island.of.Lost.Dreams.2002.BluRay.1080p.DTS-HD.MA.5.1.AVC.REMUX-FraMeSToR`
- `Are.You.Being.Served.1977.1080p.BluRay.x264.FLAC.2.0-HANDJOB`

### 3. Find or Create Destination Folders

Search for matching folders in the destination using flexible matching:

```bash
# For TV shows - search by show name
ls -d /Volumes/media/Video/TV/*keyword* 2>/dev/null

# For movies - search by movie name
ls -d /Volumes/media/Video/Movies/*keyword* 2>/dev/null
```

**Season folder naming:** Use `Season XX` format (zero-padded). If both `Season 01` and `Season 1` exist, prefer `Season 01`.

#### Creating New Movie Folders

If no matching movie folder exists (this is the norm), create one using the naming convention:

```
<Movie Name> (<Year>)
```

Examples:
- `Spy.Kids.2.Island.of.Lost.Dreams.2002.BluRay...` → `Spy Kids 2 Island of Lost Dreams (2002)`
- `Are.You.Being.Served.1977.1080p.BluRay...` → `Are You Being Served (1977)`

```bash
mkdir -p "/Volumes/media/Video/Movies/Spy Kids 2 Island of Lost Dreams (2002)/"
```

#### Creating New Series Folders

If no matching series folder exists, create one using the naming convention:

```
<Series Name> (<Year>)
```

Examples:
- `Doc.2025.S02E15...` → `Doc (2025)`
- `The.Beauty.S01E06...` → `The Beauty (2025)` (use current year if not in filename)
- `The.Traitors.2023.S04E09...` → `The Traitors (2023)`

```bash
mkdir -p "/Volumes/media/Video/TV/The Beauty (2025)/Season 01/"
```

Note: Extract the year from the filename if present (e.g., `Show.2023.S01E01`). If no year is in the filename, ask the user or look it up.

### 4. Process Files

**For RAR archives:**
```bash
unrar e -o+ "/full/path/to/source/folder/filename.rar" "/destination/path/"
```

The `-e` flag extracts without directory structure, `-o+` overwrites existing files. Always use absolute paths to avoid `cd` commands which trigger permission prompts.

**For MKV/video files (no RAR):**
```bash
mv "/source/file.mkv" "/destination/path/"
```

**For extensionless video files:**
Some downloads contain video files without extensions (random string filenames). If a file has no extension but is large (>100MB), it's likely a video file. Rename it using the parent folder name with `.mkv` extension:

```bash
# Check for large extensionless files
find "/source/folder/" -type f -size +100M ! -name "*.*"

# Rename using folder name
mv "/source/folder/randomstring" "/destination/path/Folder.Name.S01E01.1080p.WEB.h264-GROUP.mkv"
```

The destination filename should be derived from the source folder name (the release name).

### 5. Verify and Clean Up

After successful extraction/move:
1. Verify the file exists in destination: `ls -la "/destination/path/" | grep -i "filename"`
2. Ask user if they want to delete source folders
3. If yes, delete ALL folders in a single `rm -rf` command to avoid multiple permission prompts:
   ```bash
   rm -rf "/folder1" "/folder2" "/folder3" && echo "Cleanup complete"
   ```

## Important Notes

- RAR archives are typically split across multiple files (`.rar`, `.r00`, `.r01`, etc.). Only run `unrar` on the `.rar` file.
- Source folders often have nested structure: `Folder/Folder/files.rar` - navigate into the nested folder.
- Some movies may already be extracted MKV files rather than RAR archives.
- **Extensionless files:** Some downloads have video files with random/garbled names and no extension. If a file is >100MB and has no extension, treat it as an MKV. Use the source folder name (release name) as the destination filename with `.mkv` extension.
- Always use quotes around paths containing spaces.
- Create season folders if they don't exist: `mkdir -p "/path/Season XX/"`
- If no matching destination folder is found, create one using the naming conventions above.

## Example Session

1. User invokes `/process-downloads`
2. List contents of `/Volumes/complete/Series/` and `/Volumes/complete/Movies/`
3. For each item found:
   - Parse the name to extract show/movie info
   - Find the matching destination folder
   - Check for RAR files or video files
   - Extract/move to destination
   - Verify success
4. Ask user about cleanup
5. Report summary of processed items

## Error Handling

- If `unrar` is not installed, inform user to install it (`brew install unrar`)
- If destination folder not found, create it using the naming conventions (see "Creating New Folders" sections above)
- If year cannot be determined from filename, ask the user
- If extraction fails, report the error and continue with remaining items
