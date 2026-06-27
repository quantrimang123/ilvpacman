-- Example ilvpacman init.lua
--
-- This file is a complete template for ilvpacman.opt. Copy entries you need,
-- or keep all of them and tune values. Command-line flags still override
-- these values.

ilvpacman.opt.aururl = "https://aur.archlinux.org"
ilvpacman.opt.aurrpcurl = ""
ilvpacman.opt.build_dir = os.getenv("HOME") .. "/.cache/ilvpacman"
ilvpacman.opt.editor = os.getenv("EDITOR") or os.getenv("VISUAL") or "vi"
ilvpacman.opt.editor_flags = ""
ilvpacman.opt.makepkg_bin = "makepkg"
ilvpacman.opt.makepkg_conf = ""
ilvpacman.opt.pacman_bin = "pacman"
ilvpacman.opt.pacman_conf = "/etc/pacman.conf"
ilvpacman.opt.redownload = "no"
ilvpacman.opt.git_bin = "git"
ilvpacman.opt.gpg_bin = "gpg"
ilvpacman.opt.gpg_flags = ""
ilvpacman.opt.mflags = ""
ilvpacman.opt.sort_by = ""
ilvpacman.opt.search_by = "name-desc"
ilvpacman.opt.git_flags = ""
ilvpacman.opt.remove_make = "ask"
ilvpacman.opt.sudo_bin = "sudo"
ilvpacman.opt.sudo_flags = ""
ilvpacman.opt.rebuild = "no"
ilvpacman.opt.answer_clean = ""
ilvpacman.opt.answer_diff = ""
ilvpacman.opt.answer_edit = ""

ilvpacman.opt.request_split_n = 150
ilvpacman.opt.completion_refresh_time = 7
ilvpacman.opt.max_concurrent_downloads = 1

ilvpacman.opt.bottom_up = true
ilvpacman.opt.sudo_loop = false
ilvpacman.opt.devel = false
ilvpacman.opt.clean_after = false
ilvpacman.opt.keep_src = false
ilvpacman.opt.provides = true
ilvpacman.opt.pgp_fetch = true
ilvpacman.opt.clean_menu = true
ilvpacman.opt.diff_menu = true
ilvpacman.opt.edit_menu = false
ilvpacman.opt.combined_upgrade = true
ilvpacman.opt.use_ask = false
ilvpacman.opt.batch_install = false
ilvpacman.opt.single_line_results = false
ilvpacman.opt.separate_sources = true
ilvpacman.opt.debug = false
ilvpacman.opt.rpc = true
ilvpacman.opt.double_confirm = true

-- Hooks
-- Run Lua before ilvpacman prints the upgrade exclusion menu. Return package names
-- from event.data.upgrades to pre-exclude them. Set skip_menu = false, or omit
-- it, to show the native menu after these exclusions are applied.
--
-- ilvpacman.create_autocmd("UpgradeSelect", {
--   desc = "skip recently modified AUR upgrades",
--   callback = function(event)
--     local exclude = {}
--     local recent_cutoff = os.time() - (3 * 24 * 60 * 60)
--     for _, pkg in ipairs(event.data.upgrades) do
--       if pkg.repository == "aur" and pkg.last_modified >= recent_cutoff then
--         ilvpacman.log.warn("pre-excluding recently modified AUR package:", pkg.name)
--         table.insert(exclude, pkg.name)
--       end
--     end
--
--     return { exclude = exclude, skip_menu = false }
--   end,
-- })
--
-- Run Lua after AUR PKGBUILD repos are downloaded/merged and before the
-- clean/diff/edit menus or source downloads.
--
-- ilvpacman.create_autocmd("AURPreInstall", {
--   desc = "inspect or modify AUR package files",
--   callback = function(event)
--     if event.data.pkgbuild:match("forbidden.example") then
--       ilvpacman.log.warn(event.match .. ": forbidden source URL")
--       ilvpacman.abort(event.match .. ": forbidden source URL")
--     end
--
--     -- File edits are picked up by later menus and build steps.
--     -- local path = event.data.pkgbuild_path
--     -- local f = assert(io.open(path, "a"))
--     -- f:write("\n# edited by ilvpacman init.lua\n")
--     -- f:close()
--   end,
-- })
--
-- Run Lua after ilvpacman downloads/verifies package sources and before builds or
-- installs. AURPostDownload receives the same payload shape as AURPreInstall.
--
-- ilvpacman.create_autocmd("AURPostDownload", {
--   desc = "block forbidden source URLs after download",
--   callback = function(event)
--     if event.data.pkgbuild:match("forbidden.example") then
--       ilvpacman.abort(event.match .. ": forbidden source URL")
--     end
--   end,
-- })
--
-- Run Lua once after a successful install/upgrade transaction (skipped on
-- --downloadonly). The callback is fire-and-forget; returning has no effect.
--
-- ilvpacman.create_autocmd("PostInstall", {
--   desc = "log every package ilvpacman installed",
--   callback = function(event)
--     for _, pkg in ipairs(event.data.packages) do
--       ilvpacman.log.info(pkg.name .. " " .. pkg.version .. " (" .. pkg.source .. ")")
--     end
--   end,
-- })
--
-- Run Lua during -Ss / -S number menu after ranking, before display. Return
-- an ordered array of {source=, name=} to filter/reorder; nil = unchanged.
--
-- ilvpacman.create_autocmd("SearchFilter", {
--   desc = "show only AUR results",
--   callback = function(event)
--     local out = {}
--     for _, r in ipairs(event.data.results) do
--       if r.source == "aur" then
--         out[#out + 1] = { source = r.source, name = r.name }
--       end
--     end
--     return out
--   end,
-- })
