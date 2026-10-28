# 06. Upload the synthetic files

[Previous](05-schemas-and-raw-volume.md) | [Home](../README.md) |
[Next: Bronze](07-ingest-bronze.md)

**Goal:** land the original fixture without automatically creating tables.

**Requires:** `USE CATALOG`, `USE SCHEMA`, and `WRITE VOLUME` on the landing volume.

1. Inspect the repository's [three CSVs](../data/raw/) and
   [dataset dictionary](../data/README.md).
2. In Databricks, choose **New > Add or upload data > Upload files to a volume**,
   or the corresponding Catalog Explorer upload action.
3. Select only `teams.csv`, `projects.csv`, and `work_items.csv` from `data\raw`.
4. Choose `/Volumes/integration_lab/raw/source_files/` as the destination.
5. Upload, then open the volume to check the files.

| File | Expected data rows |
| --- | --- |
| teams.csv | 4 |
| projects.csv | 8 |
| work_items.csv | 44 |

**Expected:** all three nonempty files are directly inside the volume, with no
extra nested folder. The Bronze notebook will validate their contents.

Do not repair duplicates, blanks, or invalid values: they are intentional inputs
to the cleaning exercise. Do not upload the whole repository, answer key, or slides.
Inspect existing files before overwriting them.

Uploading incurs storage usage; it does not require notebook compute.
Keep the source files after ingestion.

Reference: [upload to a volume](https://learn.microsoft.com/azure/databricks/volumes/volume-files#upload-files-to-a-volume).
