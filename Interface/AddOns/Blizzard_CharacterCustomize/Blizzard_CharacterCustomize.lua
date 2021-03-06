local showDebugTooltipInfo = GetCVarBool("debugTargetInfo");

CharCustomizeFrameWithTooltipMixin = {};

function CharCustomizeFrameWithTooltipMixin:OnLoad()
	if self.simpleTooltipLine then
		self:AddTooltipLine(self.simpleTooltipLine, HIGHLIGHT_FONT_COLOR);
	end
end

function CharCustomizeFrameWithTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
end

function CharCustomizeFrameWithTooltipMixin:AddTooltipLine(lineText, lineColor)
	if not self.tooltipLines then
		self.tooltipLines = {};
	end

	table.insert(self.tooltipLines, {text = lineText, color = lineColor or NORMAL_FONT_COLOR});
end

function CharCustomizeFrameWithTooltipMixin:AddBlankTooltipLine()
	self:AddTooltipLine(" ");
end

function CharCustomizeFrameWithTooltipMixin:GetAppropriateTooltip()
	return UIParent and GameNoHeaderTooltip or GlueTrueScaleNoHeaderTooltip;
end

function CharCustomizeFrameWithTooltipMixin:SetupAnchors(tooltip)
	if self.tooltipAnchor == "ANCHOR_TOPRIGHT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
	elseif self.tooltipAnchor == "ANCHOR_TOPLEFT" then
		tooltip:SetOwner(self, "ANCHOR_NONE");
		tooltip:SetPoint("TOPRIGHT", self, "TOPLEFT", -self.tooltipXOffset, self.tooltipYOffset);
	else
		tooltip:SetOwner(self, self.tooltipAnchor, self.tooltipXOffset, self.tooltipYOffset);
	end
end

function CharCustomizeFrameWithTooltipMixin:AddExtraStuffToTooltip()
end

function CharCustomizeFrameWithTooltipMixin:OnEnter()
	if self.tooltipLines then
		local tooltip = self:GetAppropriateTooltip();

		self:SetupAnchors(tooltip);

		if self.tooltipMinWidth then
			tooltip:SetMinimumWidth(self.tooltipMinWidth);
		end

		if self.tooltipPadding then
			tooltip:SetPadding(self.tooltipPadding, self.tooltipPadding, self.tooltipPadding, self.tooltipPadding);
		end

		for _, lineInfo in ipairs(self.tooltipLines) do
			GameTooltip_AddColoredLine(tooltip, lineInfo.text, lineInfo.color);
		end

		self:AddExtraStuffToTooltip();

		tooltip:Show();
	end
end

function CharCustomizeFrameWithTooltipMixin:OnLeave()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

CharCustomizeSmallButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeSmallButtonMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	self.Icon:SetAtlas(self.iconAtlas);
end

function CharCustomizeSmallButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPLEFT", self, "BOTTOMRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeSmallButtonMixin:OnMouseDown()
	if self:IsEnabled() then
		self.Icon:SetPoint("CENTER", self.PushedTexture);
	end
end

function CharCustomizeSmallButtonMixin:OnMouseUp()
	self.Icon:SetPoint("CENTER");
end

function CharCustomizeSmallButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_LOOK);
end

CharCustomizeResetCameraButtonMixin = {};

function CharCustomizeResetCameraButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);
	CharCustomizeFrame:ResetCharacterRotation();
	CharCustomizeFrame:UpdateCameraMode();
end

CharCustomizeRandomizeAppearanceButtonMixin = {};

function CharCustomizeRandomizeAppearanceButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);
	CharCustomizeFrame:RandomizeAppearance();
end

CharCustomizeClickOrHoldButtonMixin = {};

function CharCustomizeClickOrHoldButtonMixin:OnHide()
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

function CharCustomizeClickOrHoldButtonMixin:DoClickAction()
end

function CharCustomizeClickOrHoldButtonMixin:DoHoldAction(elapsed)
end

function CharCustomizeClickOrHoldButtonMixin:OnClick()
	CharCustomizeSmallButtonMixin.OnClick(self);

	if not self.wasHeld then
		self:DoClickAction();
	end
end

function CharCustomizeClickOrHoldButtonMixin:OnUpdate(elapsed)
	if self.waitTimerSeconds then
		self.waitTimerSeconds = self.waitTimerSeconds - elapsed;
		if self.waitTimerSeconds >= 0 then
			return;
		else
			-- waitTimerSeconds is now negative, so add it to elapsed to remove any leftover wait time
			elapsed = elapsed + self.waitTimerSeconds;
			self.waitTimerSeconds = nil;
		end
	end

	self.wasHeld = true;
	self:DoHoldAction(elapsed);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseDown()
	CharCustomizeSmallButtonMixin.OnMouseDown(self);
	self.wasHeld = false;
	self.waitTimerSeconds = self.holdWaitTimeSeconds;
	self:SetScript("OnUpdate", self.OnUpdate);
end

function CharCustomizeClickOrHoldButtonMixin:OnMouseUp()
	CharCustomizeSmallButtonMixin.OnMouseUp(self);
	self.waitTimerSeconds = nil;
	self:SetScript("OnUpdate", nil);
end

CharCustomizeZoomButtonMixin = CreateFromMixins(CharCustomizeClickOrHoldButtonMixin);

function CharCustomizeZoomButtonMixin:DoClickAction()
	CharCustomizeFrame:ZoomCamera(self.clickAmount);
end

function CharCustomizeZoomButtonMixin:DoHoldAction(elapsed)
	CharCustomizeFrame:ZoomCamera(self.holdAmountPerSecond * elapsed);
end

CharCustomizeRotateButtonMixin = CreateFromMixins(CharCustomizeClickOrHoldButtonMixin);

function CharCustomizeRotateButtonMixin:DoClickAction()
	CharCustomizeFrame:RotateCharacter(self.clickAmount);
end

function CharCustomizeRotateButtonMixin:DoHoldAction(elapsed)
	CharCustomizeFrame:RotateCharacter(self.holdAmountPerSecond * elapsed);
end

CharCustomizeFrameWithExpandableTooltipMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeFrameWithExpandableTooltipMixin:ClearTooltipLines()
	self.tooltipLines = nil;
	self.expandedTooltipFrame = nil;
end

function CharCustomizeFrameWithExpandableTooltipMixin:AddExpandedTooltipFrame(frame)
	self.expandedTooltipFrame = frame;
end

local tooltipsExpanded = false;

function CharCustomizeFrameWithExpandableTooltipMixin:AddExtraStuffToTooltip()
	if self.expandedTooltipFrame then
		local tooltip = self:GetAppropriateTooltip();

		if tooltipsExpanded then
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_InsertFrame(tooltip, self.expandedTooltipFrame);
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_LESS);
		else
			GameTooltip_AddBlankLineToTooltip(tooltip);
			GameTooltip_AddDisabledLine(tooltip, RIGHT_CLICK_FOR_MORE);
		end
	end
end

CharCustomizeMaskedButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeMaskedButtonMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);

	self.CircleMask:SetPoint("TOPLEFT", self, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);

	local hasRingSizes = self.ringWidth and self.ringHeight;
	if hasRingSizes then
		self.Ring:SetAtlas(self.ringAtlas);
		self.Ring:SetSize(self.ringWidth, self.ringHeight);
	else
		self.Ring:SetAtlas(self.ringAtlas, true);
	end

	self.NormalTexture:AddMaskTexture(self.CircleMask);
	self.PushedTexture:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:AddMaskTexture(self.CircleMask);
	self.DisabledOverlay:SetAlpha(self.disabledOverlayAlpha);

	if self.flipTextures then
		self.NormalTexture:SetTexCoord(1, 0, 0, 1);
		self.PushedTexture:SetTexCoord(1, 0, 0, 1);
	end

	if self.BlackBG then
		self.BlackBG:AddMaskTexture(self.CircleMask);
	end
end

function CharCustomizeMaskedButtonMixin:SetEnabledState(enabled)
	self:SetEnabled(enabled);

	local normalTex = self:GetNormalTexture();
	if normalTex then
		normalTex:SetDesaturated(not enabled);
	end

	self.Ring:SetAtlas(self.ringAtlas..(enabled and "" or "-disabled"));

	self.DisabledOverlay:SetShown(not enabled);
end

function CharCustomizeMaskedButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.CheckedTexture:SetPoint("CENTER", self.PushedTexture);
		self.CircleMask:SetPoint("TOPLEFT", self.PushedTexture, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
		self.CircleMask:SetPoint("BOTTOMRIGHT", self.PushedTexture, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
		self.Ring:SetPoint("CENTER", self.PushedTexture);
	end
end

function CharCustomizeMaskedButtonMixin:OnMouseUp(button)
	if button == "RightButton" and self.expandedTooltipFrame then
		tooltipsExpanded = not tooltipsExpanded;
		if GetMouseFocus() == self then
			self:OnEnter();
		end
	end

	self.CheckedTexture:SetPoint("CENTER");
	self.CircleMask:SetPoint("TOPLEFT", self, "TOPLEFT", self.circleMaskSizeOffset, -self.circleMaskSizeOffset);
	self.CircleMask:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -self.circleMaskSizeOffset, self.circleMaskSizeOffset);
	self.Ring:SetPoint("CENTER");
end

function CharCustomizeMaskedButtonMixin:UpdateHighlightTexture()
	if self:GetChecked() then
		self.HighlightTexture:SetAtlas("charactercreate-ring-select");
		self.HighlightTexture:SetPoint("TOPLEFT", self.CheckedTexture);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.CheckedTexture);
	else
		self.HighlightTexture:SetAtlas(self.ringAtlas);
		self.HighlightTexture:SetPoint("TOPLEFT", self.Ring);
		self.HighlightTexture:SetPoint("BOTTOMRIGHT", self.Ring);
	end
end

CharacterCreateAlteredFormButtonMixin = CreateFromMixins(CharCustomizeFrameWithExpandableTooltipMixin, CharCustomizeMaskedButtonMixin);

function CharacterCreateAlteredFormButtonMixin:SetupAlteredFormButton(raceData, selectedSexID, viewingAlteredForm, isAlteredForm, layoutIndex)
	self.layoutIndex = layoutIndex;
	self.isAlteredForm = isAlteredForm;

	local sexString;
	if selectedSexID == Enum.Unitsex.Male then
		sexString = "male";
	else
		sexString = "female";
	end

	local useHiRez = true;
	local atlas = GetRaceAtlas(strlower(raceData.fileName), sexString, useHiRez);
	self:SetNormalAtlas(atlas);
	self:SetPushedAtlas(atlas);

	self:ClearTooltipLines();
	self:AddTooltipLine(CHARACTER_FORM:format(raceData.name));

	if viewingAlteredForm == isAlteredForm then
		self:SetChecked(true);
	else
		self:SetChecked(false);
	end

	self:UpdateHighlightTexture();
end

function CharacterCreateAlteredFormButtonMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharacterCreateAlteredFormButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCustomizeFrame:SetViewingAlteredForm(self.isAlteredForm);
end

CharCustomizeCategoryButtonMixin = CreateFromMixins(CharCustomizeMaskedButtonMixin);

function CharCustomizeCategoryButtonMixin:SetCategory(categoryData, selectedCategoryID)
	self.categoryData = categoryData;
	self.categoryID = categoryData.id;
	self.layoutIndex = categoryData.orderIndex;

	self:ClearTooltipLines();
	self:AddTooltipLine(categoryData.name);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Category ID: "..categoryData.id, HIGHLIGHT_FONT_COLOR);
	end

	if selectedCategoryID == categoryData.id then
		self:SetChecked(true);
		self:SetNormalAtlas(categoryData.selectedIcon);
		self:SetPushedAtlas(categoryData.selectedIcon);
	else
		self:SetChecked(false);
		self:SetNormalAtlas(categoryData.icon);
		self:SetPushedAtlas(categoryData.icon);
	end

	self:UpdateHighlightTexture();
end

function CharCustomizeCategoryButtonMixin:OnClick()
	PlaySound(SOUNDKIT.GS_CHARACTER_CREATION_CLASS);
	CharCustomizeFrame:SetSelectedCatgory(self.categoryData);
end

CharCustomizeOptionSliderMixin = CreateFromMixins(SliderWithButtonsAndLabelMixin, CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionSliderMixin:OnLoad()
	CharCustomizeFrameWithTooltipMixin.OnLoad(self);
	ResizeLayoutMixin.OnLoad(self);
end

function CharCustomizeOptionSliderMixin:SetupAnchors(tooltip)
	tooltip:SetOwner(self, "ANCHOR_NONE");
	tooltip:SetPoint("BOTTOMLEFT", self.Slider.Thumb, "TOPRIGHT", self.tooltipXOffset, self.tooltipYOffset);
end

function CharCustomizeOptionSliderMixin:SetupOption(optionData)
	self.optionData = optionData;
	self.layoutIndex = optionData.orderIndex;
	self.currentChoice = nil;

	local minValue = 1;
	local maxValue = #optionData.choices;
	local valueStep = 1;
	self:SetupSlider(minValue, maxValue, optionData.currentChoiceIndex, valueStep, optionData.name);
end

function CharCustomizeOptionSliderMixin:OnSliderValueChanged(value, userInput)
	SliderWithButtonsAndLabelMixin.OnSliderValueChanged(self, value);

	local newChoice = Round(value);
	local newChoiceData = self.optionData.choices[newChoice];

	local needToUpdateModel = false;
	if userInput and self.currentChoice ~= newChoice then
		needToUpdateModel = true;
	end

	self.currentChoice = newChoice;

	local currentChoiceTooltip = (newChoiceData.name ~= "") and CHARACTER_CUSTOMIZATION_CHOICE_TOOLTIP:format(newChoice, newChoiceData.name) or newChoice;

	self:ClearTooltipLines();
	self:AddTooltipLine(currentChoiceTooltip);

	if showDebugTooltipInfo then
		self:AddBlankTooltipLine();
		self:AddTooltipLine("Option ID: "..self.optionData.id, HIGHLIGHT_FONT_COLOR);
		self:AddTooltipLine("Choice ID: "..newChoiceData.id, HIGHLIGHT_FONT_COLOR);
	end

	local mouseFocus = GetMouseFocus();
	if DoesAncestryInclude(self, mouseFocus) and (mouseFocus:GetObjectType() ~= "Button") then
		self:OnEnter();
	end

	if needToUpdateModel then
		CharCustomizeFrame:SetCustomizationChoice(self.optionData.id, newChoiceData.id);
	end
end

CharCustomizeOptionCheckButtonMixin = CreateFromMixins(CharCustomizeFrameWithTooltipMixin);

function CharCustomizeOptionCheckButtonMixin:SetupOption(optionData)
	self.optionData = optionData;
	self.layoutIndex = optionData.orderIndex;
	self.checked = (optionData.currentChoiceIndex == 2);

	self.Label:SetText(optionData.name);
	self.Button:SetChecked(self.checked);
end

function CharCustomizeOptionCheckButtonMixin:OnCheckButtonClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	self.checked = not self.checked;

	local newChoiceIndex = self.checked and 2 or 1;
	local newChoiceData = self.optionData.choices[newChoiceIndex];

	CharCustomizeFrame:SetCustomizationChoice(self.optionData.id, newChoiceData.id);
end

CharCustomizeMixin = {};

function CharCustomizeMixin:OnLoad()
	self.pools = CreateFramePoolCollection();
	self.pools:CreatePool("CHECKBUTTON", self.Categories, "CharCustomizeCategoryButtonTemplate");
	self.pools:CreatePool("FRAME", self.Options, "CharCustomizeOptionCheckButtonTemplate");

	-- Keep the sliders in a different pool because we need to NEVER release a slider when the player is dragging the thumb
	-- Otherwise after the release/re-acquire the slider they are dragging may belong to a different option
	self.sliderPool = CreateFramePool("FRAME", self.Options, "CharCustomizeOptionSliderTemplate");

	-- Keep the altered forms buttons in a different pool because we only want to release those when we enter this screen
	self.alteredFormsPool = CreateFramePool("CHECKBUTTON", self.AlteredForms, "CharCustomizeAlteredFormButtonTemplate");
end

function CharCustomizeMixin:AttachToParentFrame(parentFrame)
	self.parentFrame = parentFrame;
	self:SetParent(parentFrame);
end

function CharCustomizeMixin:SetCustomizationChoice(optionID, choiceID)
	self.parentFrame:SetCustomizationChoice(optionID, choiceID);
end

function CharCustomizeMixin:Reset()
	self.selectedCategoryData = nil;
end

function CharCustomizeMixin:NeedsCategorySelected()
	if not self.selectedCategoryData then
		return true;
	end

	for _, categoryData in ipairs(self.categories) do
		if self.selectedCategoryData.id == categoryData.id then
			return false;
		end
	end

	return true;
end

function CharCustomizeMixin:UpdateAlteredFormButtons()
	self.alteredFormsPool:ReleaseAll();

	if self.selectedRaceData.alternateFormRaceData then
		local normalForm = self.alteredFormsPool:Acquire();
		normalForm:SetupAlteredFormButton(self.selectedRaceData, self.selectedSexID, self.viewingAlteredForm, false, 1);
		normalForm:Show();

		local alteredForm = self.alteredFormsPool:Acquire();
		alteredForm:SetupAlteredFormButton(self.selectedRaceData.alternateFormRaceData, self.selectedSexID, self.viewingAlteredForm, true, 2);
		alteredForm:Show();
	end

	self.AlteredForms:Layout();
end

function CharCustomizeMixin:SetSelectedData(selectedRaceData, selectedSexID, viewingAlteredForm)
	self.selectedRaceData = selectedRaceData;
	self.selectedSexID = selectedSexID;
	self.viewingAlteredForm = viewingAlteredForm;
	self:UpdateAlteredFormButtons();
end

function CharCustomizeMixin:SetViewingAlteredForm(viewingAlteredForm)
	if self.viewingAlteredForm ~= viewingAlteredForm then
		self.viewingAlteredForm = viewingAlteredForm;
		self.parentFrame:SetViewingAlteredForm(viewingAlteredForm);
	end

	self:UpdateAlteredFormButtons();
end

local function SortCategories(a, b)
	return a.orderIndex < b.orderIndex;
end

function CharCustomizeMixin:SetCustomizations(categories)
	self.categories = categories;

	local keepCustomZoom = (self.selectedCategoryData ~= nil);

	if self:NeedsCategorySelected() then
		table.sort(self.categories, SortCategories);
		self:SetSelectedCatgory(self.categories[1], keepCustomZoom);
	else
		self:SetSelectedCatgory(self.selectedCategoryData, keepCustomZoom);
	end
end

function CharCustomizeMixin:GetOptionPool(optionType)
	if optionType == Enum.ChrCustomizationOptionType.Slider then
		return self.sliderPool;
	elseif optionType == Enum.ChrCustomizationOptionType.Checkbox then
		return self.pools:GetPool("CharCustomizeOptionCheckButtonTemplate");
	end
end

-- Releases all sliders EXCEPT the one the player is currently dragging (if they are dragging one).
-- Returns the currently dragging slider if there was one
function CharCustomizeMixin:ReleaseNonDraggingSliders()
	local draggingSlider;
	local releaseSliders = {};

	for optionSlider in pairs(self.sliderPool.activeObjects) do
		if optionSlider.Slider:IsDraggingThumb() then
			draggingSlider = optionSlider;
		else
			table.insert(releaseSliders, optionSlider);
		end
	end

	for _, releaseSlider in ipairs(releaseSliders) do
		self.sliderPool:Release(releaseSlider);
	end

	return draggingSlider;
end

function CharCustomizeMixin:UpdateOptionButtons()
	self.pools:ReleaseAll();

	local draggingSlider = self:ReleaseNonDraggingSliders();

	for _, categoryData in ipairs(self.categories) do
		local button = self.pools:Acquire("CharCustomizeCategoryButtonTemplate");
		button:SetCategory(categoryData, self.selectedCategoryData.id);
		button:Show();

		if self.selectedCategoryData.id == categoryData.id then
			for _, optionData in ipairs(categoryData.options) do
				local optionPool = self:GetOptionPool(optionData.optionType);
				if optionPool then
					if draggingSlider and draggingSlider.optionData.id == optionData.id then
						-- Do nothing. This option is being dragged and so was not released
					else
						local optionFrame = optionPool:Acquire();
						optionFrame:SetupOption(optionData);
						optionFrame:Show();
					end
				end
			end
		end
	end

	self.Categories:Layout();
	self.Options:Layout();
end

function CharCustomizeMixin:UpdatetModelDressState()
	self.parentFrame:SetModelDressState(not self.selectedCategoryData.undressModel);
end

function CharCustomizeMixin:UpdateZoomButtonStates()
	local currentZoom = self.parentFrame:GetCurrentCameraZoom();

	local zoomOutEnabled = (currentZoom > 0);
	self.SmallButtons.ZoomOutButton:SetEnabled(zoomOutEnabled);
	self.SmallButtons.ZoomOutButton.Icon:SetDesaturated(not zoomOutEnabled);

	local zoomInEnabled = (currentZoom < 100);
	self.SmallButtons.ZoomInButton:SetEnabled(zoomInEnabled);
	self.SmallButtons.ZoomInButton.Icon:SetDesaturated(not zoomInEnabled);
end

function CharCustomizeMixin:UpdateCameraMode(keepCustomZoom)
	self.parentFrame:SetCameraZoomLevel(self.selectedCategoryData.cameraZoomLevel, keepCustomZoom);
	self:UpdateZoomButtonStates();
end

function CharCustomizeMixin:SetSelectedCatgory(categoryData, keepCustomZoom)
	self.selectedCategoryData = categoryData;
	self:UpdateOptionButtons();
	self:UpdatetModelDressState();
	self:UpdateCameraMode(keepCustomZoom);
end

function CharCustomizeMixin:ResetCharacterRotation()
	self.parentFrame:ResetCharacterRotation();
end

function CharCustomizeMixin:OnMouseWheel(delta)
	self:ZoomCamera((delta > 0) and 20 or -20);
end

function CharCustomizeMixin:ZoomCamera(zoomAmount)
	self.parentFrame:ZoomCamera(zoomAmount);
	self:UpdateZoomButtonStates();
end

function CharCustomizeMixin:RotateCharacter(rotationAmount)
	self.parentFrame:RotateCharacter(rotationAmount);
end

function CharCustomizeMixin:RandomizeAppearance()
	self.parentFrame:RandomizeAppearance();
end
