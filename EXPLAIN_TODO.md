# Explain TODO

Ce fichier sert de checklist pendant la relecture de l'architecture.

Regle :
- une fonction est cochée quand on l'a expliquée ensemble
- un fichier est coché quand toutes ses fonctions ont été expliquées
- pour les fichiers sans fonction, on coche la ligne quand on a expliqué leur rôle global

## `conf.lua`
- [ ] Fichier complet
- [ ] `love.conf`

## `main.lua`
- [ ] Fichier complet
- [ ] `updateButtons`
- [x] `love.load`
- [x] `love.update`
- [x] `love.draw`
- [ ] `love.mousepressed`
- [ ] `love.mousereleased`
- [ ] `love.keypressed`
- [ ] `love.wheelmoved`

## `src/app/game_state.lua`
- [ ] Fichier complet
- [ ] `game_state.create`

## `src/app/input.lua`
- [x] Fichier complet
- [x] `input.mousepressed`
- [x] `input.mousereleased`
- [x] `input.keypressed`
- [x] `input.wheelmoved`

## `src/app/input_menu.lua`
- [x] Fichier complet
- [x] `input_menu.handleMenuClick`
- [x] `input_menu.handleSetupClick`

## `src/app/input_play.lua`
- [ ] Fichier complet
- [ ] `input_play.handleClick`
- [ ] `input_play.handleRelease`
- [ ] `input_play.handleKey`

## `src/app/input_round_clear.lua`
- [ ] Fichier complet
- [ ] `input_round_clear.handleClick`

## `src/app/input_shared.lua`
- [ ] Fichier complet
- [ ] `shared.handleOptionsClick`

## `src/app/navigation.lua`
- [ ] Fichier complet
- [ ] `navigation.getMayorById`
- [ ] `navigation.selectRelativeMayor`
- [ ] `navigation.openMenu`

## `src/app/profile.lua`
- [ ] Fichier complet
- [ ] `deepCopy`
- [ ] `serialize`
- [ ] `ensureDefaults`
- [ ] `profile.load`
- [ ] `profile.save`
- [ ] `profile.getData`
- [ ] `profile.applyPreferences`
- [ ] `profile.setScoringSpeed`
- [ ] `profile.setVideoMode`
- [ ] `profile.setConfirmEmptyBuildEnabled`
- [ ] `profile.resetAll`
- [ ] `profile.isMayorUnlocked`
- [ ] `profile.isDifficultyUnlocked`
- [ ] `profile.recordRunStarted`
- [ ] `profile.recordBuildingsPlaced`
- [ ] `profile.recordMoneySpent`
- [ ] `profile.recordObstacleDestroyed`
- [ ] `profile.updateBestScore`
- [ ] `profile.finishRun`

## `src/app/render.lua`
- [x] Fichier complet
- [x] `render.draw`

## `src/app/save.lua`
- [ ] Fichier complet
- [ ] `getDifficultyById`
- [ ] `serialize`
- [ ] `cloneIdList`
- [ ] `clonePendingToHandIds`
- [ ] `restoreCardsFromIds`
- [ ] `restoreDataList`
- [ ] `save.exists`
- [ ] `save.refreshFlag`
- [ ] `save.clear`
- [ ] `save.saveRun`
- [ ] `save.loadRun`

## `src/app/update.lua`
- [x] Fichier complet
- [x] `update.run`

## `src/app/video.lua`
- [ ] Fichier complet
- [ ] `video.applyMode`
- [ ] `video.setWindowed`
- [ ] `video.setFullscreen`
- [ ] `video.setBorderlessFullscreen`

## `src/constants.lua`
- [ ] Fichier complet

## `src/data/boss.lua`
- [ ] Fichier complet
- [ ] `boss.getData`

## `src/data/buildings.lua`
- [ ] Fichier complet
- [ ] `buildings.getData`
- [ ] `buildings.loadImages`

## `src/data/law.lua`
- [ ] Fichier complet
- [ ] `law.getData`

## `src/data/mayor.lua`
- [ ] Fichier complet
- [ ] `mayor.getData`

## `src/data/object.lua`
- [ ] Fichier complet
- [ ] `object.getData`

## `src/data/rounds.lua`
- [ ] Fichier complet
- [ ] `rounds.getTarget`
- [ ] `rounds.isBossRound`
- [ ] `rounds.getFinalRound`

## `src/debug/menu.lua`
- [ ] Fichier complet
- [ ] `getLabel`
- [ ] `debug_menu.draw`

## `src/debug/scenarios.lua`
- [ ] Fichier complet
- [ ] `seedDebugBoard`
- [ ] `seedPlayerCollections`
- [ ] `setDebugRound`
- [ ] `seedRoundClear`
- [ ] `debug_scenarios.start`
- [ ] `openBossIntro`

## `src/game/gameplay.lua`
- [ ] Fichier complet
- [ ] `gameplay.getDifficulty`
- [ ] `gameplay.getPendingPlacementAt`
- [ ] `getProjectedCellId`
- [ ] `gameplay.canPlaceAt`
- [ ] `gameplay.countPlacedOrCommitted`
- [ ] `gameplay.updateHandStatusMessage`
- [ ] `gameplay.beginRound`
- [ ] `gameplay.startGame`
- [ ] `gameplay.startDebugScenario`
- [ ] `gameplay.endRoundFailure`
- [ ] `gameplay.endRoundSuccess`
- [ ] `gameplay.finishResolution`
- [ ] `gameplay.finalizeBuild`
- [ ] `gameplay.updateResolution`
- [ ] `gameplay.updateRoundClear`
- [ ] `gameplay.updateBossIntro`
- [ ] `gameplay.openRoundSummary`
- [ ] `gameplay.openShop`
- [ ] `gameplay.useExplosive`
- [ ] `gameplay.applyBossBuildEffects`
- [ ] `gameplay.startNextRound`
- [ ] `gameplay.startBossRound`
- [ ] `gameplay.hasCommittedBuildings`
- [ ] `gameplay.placeCardFromHand`
- [ ] `gameplay.tryPlaceSelectedCard`
- [ ] `gameplay.removePendingPlacement`

## `src/game/grid.lua`
- [ ] Fichier complet
- [ ] `grid.init`
- [ ] `grid.generateObstacles`
- [ ] `grid.isInside`
- [ ] `grid.isFree`
- [ ] `grid.isObstacle`
- [ ] `grid.getNeighbors`
- [ ] `grid.setCell`
- [ ] `grid.setCellLevel`
- [ ] `grid.getCell`
- [ ] `grid.getCellLevel`
- [ ] `grid.getSize`
- [ ] `grid.getObstacleId`
- [ ] `grid.getCells`
- [ ] `grid.getLevels`

## `src/game/play.lua`
- [ ] Fichier complet
- [ ] `play.drawLightFrame`
- [ ] `drawLight`
- [ ] `drawCenteredSeries`
- [ ] `drawScoreProgress`
- [ ] `shouldHideHand`
- [ ] `shouldHideBoard`
- [ ] `play.drawGrid`
- [ ] `play.drawHand`
- [ ] `play.drawScorePopup`
- [ ] `play.drawHUD`

## `src/game/player.lua`
- [ ] Fichier complet
- [ ] `clearTable`
- [ ] `getLawPendingPlacementBonus`
- [ ] `player.getMaxPendingPlacements`
- [ ] `player.setMayor`
- [ ] `player.setDifficulty`
- [ ] `player.reset`
- [ ] `player.initDeck`
- [ ] `player.drawHand`
- [ ] `player.startRound`
- [ ] `player.refillHandAfterBuild`
- [ ] `player.removeCardFromHand`
- [ ] `player.returnCardToHand`
- [ ] `player.commitPlacedCards`
- [ ] `player.addCardToDiscard`
- [ ] `player.redrawHand`
- [ ] `player.consumeBuild`
- [ ] `player.setScores`
- [ ] `player.setTotalScore`
- [ ] `player.addMoney`
- [ ] `player.spendMoney`
- [ ] `player.hasLaw`
- [ ] `player.countLawCopies`
- [ ] `player.addLaw`
- [ ] `player.removeLaw`
- [ ] `player.addOwnedBuilding`
- [ ] `player.addItem`
- [ ] `player.consumeItem`

## `src/game/score.lua`
- [ ] Fichier complet
- [ ] `getAdjacencyCounts`
- [ ] `countSegmentsInRun`
- [ ] `collectLineRuns`
- [ ] `countAdjacentTowerPairs`
- [ ] `applyLawBonuses`
- [ ] `applyMayorBoardBonuses`
- [ ] `getMayorModifier`
- [ ] `applyBuildingLevel`
- [ ] `applyLeafEnjoyerRule`
- [ ] `applyBossOverrides`
- [ ] `score.getBuildingValue`
- [ ] `score.calculateBoard`

## `src/game/shop.lua`
- [ ] Fichier complet
- [ ] `cloneTable`
- [ ] `buildButton`
- [ ] `hasValue`
- [ ] `takeRandomIds`
- [ ] `takeWeightedBuildingIds`
- [ ] `takeWeightedLawIds`
- [ ] `getItemPrice`
- [ ] `isHidden`
- [ ] `collectAvailableLawIds`
- [ ] `collectAvailableBuildingIds`
- [ ] `collectAvailableItemIds`
- [ ] `shop.getDisplayPrice`
- [ ] `shop.hideEntry`
- [ ] `shop.rollOffers`
- [ ] `shop.prepareOffers`
- [ ] `shop.refreshOffers`
- [ ] `shop.updateLayout`
- [ ] `shop.buyBuilding`
- [ ] `shop.buyLaw`
- [ ] `shop.buyItem`
- [ ] `shop.sellLaw`

## `src/game/systems/bosses.lua`
- [ ] Fichier complet
- [ ] `shuffleIds`
- [ ] `collectAllCells`
- [ ] `sortCells`
- [ ] `isDestroyableByBoss`
- [ ] `bosses.buildOrder`
- [ ] `bosses.getBossForRound`
- [ ] `bosses.prepareBossIntro`
- [ ] `spawnIntroExplosion`
- [ ] `bosses.updateBossIntro`
- [ ] `bosses.applyRoundStartEffects`
- [ ] `bosses.applyBuildEffects`

## `src/game/systems/mayor_effects.lua`
- [ ] Fichier complet
- [ ] `mayor_effects.applyPersistentEffects`

## `src/game/systems/resolution.lua`
- [ ] Fichier complet
- [ ] `resolution.getResolutionStep`
- [ ] `resolution.getScorePopupDuration`
- [ ] `resolution.updateScorePopup`
- [ ] `resolution.spawnScorePopup`
- [ ] `resolveBossDestructionStep`
- [ ] `resolution.updateResolution`
- [ ] `resolution.updateRoundClear`

## `src/game/systems/round_flow.lua`
- [ ] Fichier complet
- [ ] `round_flow.getDifficulty`
- [ ] `round_flow.updateHandStatusMessage`
- [ ] `round_flow.beginRound`
- [ ] `enterPreparedRound`
- [ ] `prepareRoundState`
- [ ] `round_flow.startGame`
- [ ] `round_flow.endRoundFailure`
- [ ] `round_flow.endRoundSuccess`
- [ ] `round_flow.finishResolution`
- [ ] `round_flow.summarizeBoardBuildings`
- [ ] `round_flow.finalizeBuild`
- [ ] `startScoreResolution`
- [ ] `round_flow.openRoundSummary`
- [ ] `round_flow.openShop`
- [ ] `round_flow.startNextRound`
- [ ] `round_flow.startBossRound`

## `src/game/systems/shop_state.lua`
- [ ] Fichier complet
- [ ] `shop_state.useExplosive`

## `src/menus/game_over.lua`
- [ ] Fichier complet
- [ ] `game_over.draw`

## `src/menus/intro.lua`
- [ ] Fichier complet
- [ ] `tryLoadImage`
- [ ] `loadExplosionFrames`
- [ ] `intro.load`
- [ ] `intro.reset`
- [ ] `spawnExplosion`
- [ ] `spawnRandomScreenExplosion`
- [ ] `spawnCenterBurst`
- [ ] `intro.update`
- [ ] `intro.isFinished`
- [ ] `intro.draw`

## `src/menus/menu.lua`
- [ ] Fichier complet
- [ ] `menu.draw`

## `src/menus/setup.lua`
- [ ] Fichier complet
- [ ] `getLockedMayor`
- [ ] `setup.draw`

## `src/menus/stats.lua`
- [ ] Fichier complet
- [ ] `stats_scene.draw`

## `src/menus/victory.lua`
- [ ] Fichier complet
- [ ] `victory.draw`

## `src/overlays/boss_intro.lua`
- [ ] Fichier complet
- [ ] `boss_intro.draw`

## `src/overlays/codex.lua`
- [ ] Fichier complet
- [ ] `codex.draw`

## `src/overlays/confirm_build.lua`
- [ ] Fichier complet
- [ ] `confirm_build.draw`

## `src/overlays/deck_view.lua`
- [ ] Fichier complet
- [ ] `collectSections`
- [ ] `summarizeCards`
- [ ] `deck_view.draw`

## `src/overlays/options.lua`
- [ ] Fichier complet
- [ ] `options.draw`

## `src/overlays/round_clear.lua`
- [ ] Fichier complet
- [ ] `getShopCardState`
- [ ] `round_clear.draw`

## `src/ui/board.lua`
- [ ] Fichier complet
- [ ] `board.drawBuildingTile`

## `src/ui/cards.lua`
- [ ] Fichier complet
- [ ] `drawCardShell`
- [ ] `cards.drawInventoryCard`
- [ ] `cards.drawShopEntryCard`
- [ ] `cards.drawMiniCard`
- [ ] `cards.drawHandCard`
- [ ] `cards.drawHiddenHandCard`
- [ ] `cards.drawMayorCard`
- [ ] `cards.drawArrowButton`
- [ ] `cards.drawPrimaryButton`
- [ ] `cards.drawSecondaryButton`
- [ ] `cards.drawSecondaryButtonState`

## `src/ui/fonts.lua`
- [ ] Fichier complet
- [ ] `setFontFilter`
- [ ] `fonts.load`
- [ ] `fonts.applyDefault`
- [ ] `fonts.getTextFont`
- [ ] `fonts.getTitleFont`
- [ ] `fonts.getIntroTitleFont`
- [ ] `fonts.getScoreFont`
- [ ] `withFont`
- [ ] `fonts.drawOutlinedText`
- [ ] `drawAt`

## `src/ui/init.lua`
- [ ] Fichier complet
- [ ] `ui.loadAssets`
- [ ] `ui.applyDefaultFont`
- [ ] `ui.drawIntro`
- [ ] `ui.drawMenu`
- [ ] `ui.drawBossIntro`
- [ ] `ui.drawStatsModal`
- [ ] `ui.drawGrid`
- [ ] `ui.drawHand`
- [ ] `ui.drawScorePopup`
- [ ] `ui.drawHUD`
- [ ] `ui.drawOptionsModal`
- [ ] `ui.drawCodexModal`
- [ ] `ui.drawDeckModal`
- [ ] `ui.drawConfirmBuild`
- [ ] `ui.drawSetup`
- [ ] `ui.drawGameOver`
- [ ] `ui.drawVictory`
- [ ] `ui.drawRoundClear`

## `src/ui/layout.lua`
- [ ] Fichier complet
- [ ] `layout.getViewportRect`
- [ ] `layout.pointInRect`
- [ ] `layout.insetRect`
- [ ] `layout.centerRectInRect`
- [ ] `layout.getCenteredPopup`
- [ ] `layout.getPopupCloseButton`
- [ ] `layout.getPopupContentRect`
- [ ] `layout.getBottomCenteredButton`
- [ ] `layout.getScreenRect`
- [ ] `layout.distributeRowInRect`
- [ ] `layout.distributeGridInRect`
- [ ] `layout.getGridOffset`
- [ ] `layout.getCellScreenPosition`
- [ ] `layout.getScoreAnchor`
- [ ] `layout.getCellFromScreen`
- [ ] `layout.getHandMetrics`
- [ ] `layout.getCardRect`
- [ ] `layout.getCardIndexAt`
- [ ] `layout.updateButtons`

## `src/ui/theme.lua`
- [ ] Fichier complet

## `src/ui/widgets.lua`
- [ ] Fichier complet
- [ ] `widgets.drawOverlay`
- [ ] `widgets.drawPopupFrame`
- [ ] `widgets.drawCloseButton`
- [ ] `widgets.drawButton`
- [ ] `widgets.drawKeyValueList`
- [ ] `widgets.drawInfoCard`
- [ ] `widgets.drawProgressCard`
