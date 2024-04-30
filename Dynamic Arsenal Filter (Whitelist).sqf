M9SD_fnc_zeusCompHelipadCleanup = {
	comment "Determine if execution context is composition and delete the helipad.";
	if ((!isNull (findDisplay 312)) && (!isNil 'this')) then {
		if (!isNull this) then {
			if (typeOf this == 'Land_HelipadEmpty_F') then {
				deleteVehicle this;
			};
		};
	};
};
call M9SD_fnc_zeusCompHelipadCleanup;

0 = [] spawn {
	private _initREpack = [] spawn { 
		comment "RE method 2, version 4";
		"REMOTE EXEC USAGE EXMAPLE:
		
			1. Define function you want to RE
			2. Init function with RE2 method
			3. Use RE2 funtion to run remotely

			1. 
				M9_fnc_someSpicyCode = {...};
			2.
				['M9_fnc_someSpicyCode', 'spawn'] call M9SD_fnc_REinit2_V4;
			3. 
				[[], 'RE2_M9_fnc_someSpicyCodes', player] call M9SD_fnc_RE2_V4;

		";
		if (!isNil 'M9SD_fnc_RE2_V4') exitWith {}; 
		comment "Initialize Remote-Execution Package"; 
		M9SD_fnc_initRE2_V4 = { 
			M9SD_fnc_initRE2Functions_V4 = { 
				comment "Prep RE2 functions."; 
				M9SD_fnc_REinit2_V4 = {
					params [['_functionName', ''], ['_schedule', 'call']];
					private _functionNameRE2 = ''; 
					"if (isNil {_functionNames}) exitWith {''};";
					if !(_functionName isEqualType '') exitWith {''}; 
					'if (count _functionNames == 0) exitWith {''};';
					'private _functionNames = _this;';
					private _aString = ""; 
					private _namespaces = [missionNamespace, uiNamespace]; 
					{ 
						if !(_x isEqualType _aString) then {continue}; 
						private _functionName = _x; 
						_functionNameRE2 = format ["RE2_%1", _functionName]; 
						{ 
							private _namespace = _x; 
							with _namespace do { 
								if (!isNil _functionName) then { 
									private _fnc = _namespace getVariable [_functionName, {}]; 
									private _fncStr = str _fnc; 
									private _fncStr2 = "{" +  
										"removeMissionEventHandler ['EachFrame', _thisEventHandler];" +  
										"_thisArgs " + _schedule + " " + _fncStr +  
									"}"; 
									private _fncStrArr = _fncStr2 splitString ''; 
									_fncStrArr deleteAt (count _fncStrArr - 1); 
									_fncStrArr deleteAt 0; 
									_namespace setVariable [_functionNameRE2, _fncStrArr, true]; 
								}; 
							}; 
						} forEach _namespaces; 
					} forEach [_functionName]; 
					'true;';
					_functionNameRE2; 
				}; 
				M9SD_fnc_RE2_V4 = { 
					params [["_REarguments", []], ["_REfncName2", ""], ["_REtarget", player], ["_JIPparam", false]]; 
					if (
						!((missionnamespace getVariable [_REfncName2, []]) isEqualType []) && 
						!((uiNamespace getVariable [_REfncName2, []]) isEqualType [])
					) exitWith { 
						systemChat "::Error:: remoteExec failed (invalid _REfncName2 - not an array)."; 
					}; 
					if (
						(count (missionnamespace getVariable [_REfncName2, []]) == 0) && 
						(count (uiNamespace getVariable [_REfncName2, []]) == 0)
					) exitWith { 
						systemChat "::Error:: remoteExec failed (invalid _REfncName2 - empty array)."; 
						systemChat str _REfncName2; 
					}; 
					if (isNil _REfncName2) then {
						_REfncName2 = format ["RE2_%1", _REfncName2]; 
					};
					[[_REfncName2, _REarguments],{  
						if (isNil (_this # 0)) exitWith {};
						addMissionEventHandler ["EachFrame", (missionNamespace getVariable [_this # 0, ['']]) joinString '', _this # 1];  
					}] remoteExec ['call', _REtarget, _JIPparam]; 
				}; 
				comment "systemChat '[ RE2 Package ] : RE2 functions initialized.';"; 
			}; 
			M9SD_fnc_initRE2FunctionsGlobal_V4 = { 
				comment "Prep RE2 functions on all clients+jip."; 
				private _fncStr = format ["{ 
					removeMissionEventHandler ['EachFrame', _thisEventHandler]; 
					_thisArgs call %1 
				}", M9SD_fnc_initRE2Functions_V4]; 
				_fncStr = _fncStr splitString ''; 
				_fncStr deleteAt (count _fncStr - 1); 
				_fncStr deleteAt 0; 
				missionNamespace setVariable ["RE2_M9SD_fnc_initRE2Functions_V4", _fncStr, true]; 
				[["RE2_M9SD_fnc_initRE2Functions_V4", []],{  
					addMissionEventHandler ["EachFrame", (missionNamespace getVariable ["RE2_M9SD_fnc_initRE2Functions_V4", ['']]) joinString '', _this # 1];  
				}] remoteExec ['call', 0, 'RE2_M9SD_JIP_initRE2Functions_V4']; 
				comment "Delete from jip queue: remoteExec ['', 'RE2_M9SD_JIP_initRE2Functions_V4'];"; 
			}; 
			call M9SD_fnc_initRE2FunctionsGlobal_V4; 
		}; 
		call M9SD_fnc_initRE2_V4; 
		waitUntil {!isNil 'M9SD_fnc_RE2_V4'}; 
		if (true) exitWith {true}; 
	};
	waitUntil {scriptDone _initREpack};

	M9SD_fnc_moduleCompDynamicArsenalFilter = 
	{

		params [["_object", objNull]];
		'if (isNull findDisplay 312) exitWith {};';
		_zeusLogic = objNull;
		_zeusLogic = getAssignedCuratorLogic player;
		'if (isNull _zeusLogic) exitWith {};';
		M9SD_fnc_disableArsenalFilter = {
			if (!isNil 'M9SD_EH_arsenalWhitelist_FixLoadout') then 
			{
				[missionNamespace, 'ArsenalClosed', M9SD_EH_arsenalWhitelist_FixLoadout] call BIS_fnc_removeScriptedEventHandler; 
			};
			M9SD_arsenalFilterEnabled = false;
		};
		['M9SD_fnc_disableArsenalFilter', 'call'] call M9SD_fnc_REinit2_V4;
		
		M9SD_fnc_enableArsenalFilter = 
		{
			M9SD_fnc_saveOGArsenalLoadout = {
				params ["_display", "_toggleSpace"];
				player setVariable ['M9_OGArsenalLoadout', getUnitLoadout player];
			};
			if (!isNil 'M9SD_EH_arsenalWhitelist_SaveLoadout') then 
			{
				[missionNamespace, 'arsenalOpened', M9SD_EH_arsenalWhitelist_SaveLoadout] call BIS_fnc_removeScriptedEventHandler; 
			};
			M9SD_EH_arsenalWhitelist_SaveLoadout = 
			[
				missionNamespace, 
				'arsenalOpened', 
				M9SD_fnc_saveOGArsenalLoadout
			] call BIS_fnc_addScriptedEventHandler;
			M9SD_fnc_arsenalFixLoadout_01 = 
			{
				private ['_weapons', '_magazines', '_items', '_backpacks'];
				_weapons = [];
				_magazines = [];
				_items = [];
				_backpacks = [];

				M9_arsenal_activeWhitelist = missionNamespace getVariable ['M9_arsenal_activeWhitelist', [[],[],[],[]]];
				if (M9_arsenal_activeWhitelist isEqualTo [[],[],[],[]]) exitWith {};

				_weapons = M9_arsenal_activeWhitelist # 0;
				_magazines = M9_arsenal_activeWhitelist # 1;
				_items = M9_arsenal_activeWhitelist # 2;
				_backpacks = M9_arsenal_activeWhitelist # 3;
				private _bigWhitelist = _weapons + _magazines + _items + _backpacks;


				private _unit = player;
				_unitLoadout = getUnitLoadout _unit;
				_unitLoadout params [
					"_gunInfo", "_launcherInfo", "_pistolInfo",
					"_uniformInfo", "_vestInfo", "_backpackInfo",
					"_helmet", "_glasses", "_binocluarInfo",
					"_items"
				];	
				_gunInfo params ["_gun", "_gunMuzzle", "_gunPointer", "_gunOptic", "_gunMag", "_gunMag2", "_gunBipod"];
				_launcherInfo params ["_launcher", "_launcherMuzzle", "_launcherPointer", "_launcherOptic", "_launcherMag", "_launcherMag2", "_launcherBipod"];
				_pistolInfo params ["_pistol", "_pistolMuzzle", "_pistolPointer", "_pistolOptic", "_pistolMag", "_pistolMag2", "_pistolBipod"];
				_binocluarInfo params ["_binocluar", "_binocluarMuzzle", "_binocluarPointer", "_binocluarOptic", "_binocluarMag", "_binocluarMag2", "_binocluarBipod"];
				_uniformInfo params ["_uniform"];
				_vestInfo params ["_vest"];
				_backpackInfo params ["_backpack"];
				_removedItems = [];
				if !( _gun in _bigWhitelist) then {
					_unit removeWeapon _gun;
					_removedItems pushBackUnique _gun;
				};
				if !( _gunMuzzle in _bigWhitelist) then {
					_unit removePrimaryWeaponItem _gunMuzzle;
					_removedItems pushBackUnique _gunMuzzle;
				};
				if !( _gunPointer in _bigWhitelist) then {
					_unit removePrimaryWeaponItem _gunPointer;
					_removedItems pushBackUnique _gunPointer;
				};
				if !( _gunOptic in _bigWhitelist) then {
					_unit removePrimaryWeaponItem _gunOptic;
					_removedItems pushBackUnique _gunOptic;
				};
				if !( _gunBipod in _bigWhitelist) then {
					_unit removePrimaryWeaponItem _gunBipod;
					_removedItems pushBackUnique _gunBipod;
				};
				if !( _launcher in _bigWhitelist) then {
					_unit removeWeapon _launcher;
					_removedItems pushBackUnique _launcher;
				};
				if !( _launcherMuzzle in _bigWhitelist) then {
					_unit removeSecondaryWeaponItem _launcherMuzzle;
					_removedItems pushBackUnique _launcherMuzzle;
				};
				if !( _launcherPointer in _bigWhitelist) then {
					_unit removeSecondaryWeaponItem _launcherPointer;
					_removedItems pushBackUnique _launcherPointer;
				};
				if !( _launcherOptic in _bigWhitelist) then {
					_unit removeSecondaryWeaponItem _launcherOptic;
					_removedItems pushBackUnique _launcherOptic;
				};
				if !( _launcherBipod in _bigWhitelist) then {
					_unit removeSecondaryWeaponItem _launcherBipod;
					_removedItems pushBackUnique _launcherBipod;
				};
				if !( _pistol in _bigWhitelist) then {
					_unit removeWeapon _pistol;
					_removedItems pushBackUnique _pistol;
				};
				if !( _pistolMuzzle in _bigWhitelist) then {
					_unit removeHandgunItem _pistolMuzzle;
					_removedItems pushBackUnique _pistolMuzzle;
				};
				if !( _pistolPointer in _bigWhitelist) then {
					_unit removeHandgunItem _pistolPointer;
					_removedItems pushBackUnique _pistolPointer;
				};
				if !( _pistolOptic in _bigWhitelist) then {
					_unit removeHandgunItem _pistolOptic;
					_removedItems pushBackUnique _pistolOptic;
				};
				if !( _pistolBipod in _bigWhitelist) then {
					_unit removeHandgunItem _pistolBipod;
					_removedItems pushBackUnique _pistolBipod;
				};
				if !( _uniform in _bigWhitelist) then {
					removeUniform _unit;
					_removedItems pushBackUnique _uniform;
				};
				if !( _vest in _bigWhitelist) then {
					removeVest _unit;
					_removedItems pushBackUnique _vest;
				};
				if !( _backpack in _bigWhitelist) then {
					removeBackpack _unit;
					_removedItems pushBackUnique _backpack;
				};
				if !( _helmet in _bigWhitelist) then {
					removeHeadgear _unit;
					_removedItems pushBackUnique _helmet;
				};
				if !( _glasses in _bigWhitelist) then {
					removeGoggles _unit;
					_removedItems pushBackUnique _glasses;
				};
				if !( _binocluar in _bigWhitelist) then {
					_unit removeWeapon _binocluar;
					_removedItems pushBackUnique _binocluar;
				};
				{
					if !( _x in _bigWhitelist) then {
						_unit unlinkItem _x;
						_removedItems pushBackUnique _x;
					};
				} forEach _items;
				{
					if !( _x in _bigWhitelist) then {
						_unit removeItem _x;
						_removedItems pushBackUnique _x;
					};
				} forEach weapons _unit;
				{
					if !( _x in _bigWhitelist) then {
						_unit removeMagazine _x;
						_removedItems pushBackUnique _x;
					};
				} forEach magazines _unit;
				{
					if !( _x in _bigWhitelist) then {
						_unit removeItem _x;
						_removedItems pushBackUnique _x;
					};
				} forEach items _unit;
				_backpack = backpack _unit;
				if !(( _backpack) in _bigWhitelist) then {
					removeBackpack _unit;
					_removedItems pushBackUnique _backpack;
				};
				M9SD_arsenalRemovedItemsFromLoadout = _removedItems;
				if (_removedItems isEqualTo []) exitWith {};
				_removedItemNames = [];
				{
					_displayName = '';
					_displayName = getText (configFile >> "cfgVehicles" >> _x >> "displayName");
					if (_displayName == '') then 
					{
						_displayName = getText (configFile >> "cfgMagazines" >> _x >> "displayName");
					};
					if (_displayName == '') then 
					{
						_displayName = getText (configFile >> "cfgWeapons" >> _x >> "displayName");
					};
					if (_displayName == '') then 
					{
						_displayName = getText (configFile >> "CfgGlasses" >> _x >> "displayName");
					};
					if (_displayName == '') then 
					{
						_displayName = _x;
					};
					if (_displayName != '') then {_removedItemNames pushBack _displayName;};
				} forEach _removedItems;
				if (count _removedItemNames > 0) then { 
					_workshopLink = "<a href='http://arma3.com'>SUBSCRIBE to Arsenal Filter on Steam Workshop</a>";
					_message = format ["<t align='center' color='#ffd4c7'><br/><t size='1.5'>LOADOUT REJECTED<br/><t size='0.6' color='#d2d2d2'>Items Removed<br/><br/><t size='1' align='center' color='#f5ffd1'>Items were blacklisted by Zeus:<br/><br/><t size='0.7' color='#e1e1e1'>%1<br/><br/><t/>", str _removedItemNames];
					[_message, "Arsenal Filter", true, false] spawn BIS_fnc_guiMessage;
				};
			};
			comment 
			"
				[missionNamespace, 'ArsenalClosed'] call BIS_fnc_removeAllScriptedEventHandlers;
			";
			if (!isNil 'M9SD_EH_arsenalWhitelist_FixLoadout') then 
			{
				[missionNamespace, 'arsenalClosed', M9SD_EH_arsenalWhitelist_FixLoadout] call BIS_fnc_removeScriptedEventHandler; 
			};
			M9SD_EH_arsenalWhitelist_FixLoadout = 
			[
				missionNamespace, 
				'arsenalClosed', 
				M9SD_fnc_arsenalFixLoadout_01
			] call BIS_fnc_addScriptedEventHandler;
			M9SD_arsenalFilterEnabled = true;
		};
		
		['M9SD_fnc_enableArsenalFilter', 'call'] call M9SD_fnc_REinit2_V4;

		M9SD_GUIfnc_openArsenalFilterInputMethod = 
		{
			disableSerialization;
			with uiNamespace do 
			{
				createDialog 'RscDisplayEmpty';showChat true;
				showChat true;
				_d = findDisplay -1;
				_display = _d;
				
				_bkCtrl = _d ctrlCreate ['IGUIBack',-1];
				_bkCtrl ctrlSetPosition [0.427812 * safezoneW + safezoneX,0.368 * safezoneH + safezoneY,0.149531 * safezoneW,0.187 * safezoneH];
				_bkCtrl ctrlSetBackgroundColor [0,0.1,0,0.7];
				_bkCtrl ctrlCommit 0;
			
				_bkrnd = _display ctrlCreate ['RscStructuredText', -1];
				_bkrnd ctrlSetBackgroundColor [-1,-1,-1,0];
				_bkrnd ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.379 * safezoneH + safezoneY,0.139219 * safezoneW,0.033 * safezoneH];
				_bkrnd ctrlSetStructuredText parseText ("<t font='puristaBold' shadow='1' size='" + (str ((0.5 * safeZoneH) * 0.7)) + "' align='center'>Equipment Classname<br/>Input Method:</t>");
				_bkrnd ctrlCommit 0;
				
				_cancelCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_cancelCtrl ctrlSetPosition [0.520625 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.0515625 * safezoneW,0.022 * safezoneH];
				_cancelCtrl ctrlSetTooltip 'Close menu.';
				_cancelCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_cancelCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>CANCEL</t>");
				_cancelCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
					};
				}];
				_cancelCtrl ctrlCommit 0;
				
				_returnCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_returnCtrl ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.522 * safezoneH + safezoneY,0.0515625 * safezoneW,0.022 * safezoneH];
				_returnCtrl ctrlSetTooltip 'Go back.';
				_returnCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_returnCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>RETURN</t>");
				_returnCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
						[] spawn (M9SD_GUIfnc_arsenalFilter_main);
					};
				}];
				_returnCtrl ctrlCommit 0;
				
				_manualCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_manualCtrl ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.478 * safezoneH + safezoneY,0.139219 * safezoneW,0.022 * safezoneH];
				_manualCtrl ctrlSetTooltip 'Input all weapon, magazine, item, and backpack classnames manually.\n(Useful if you have a blacklist or want to save one)';
				_manualCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_manualCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>MANUAL</t>");
				_manualCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
						JAM_GUIfnc_openArsenalFilter_manual = 
						{
							systemChat '[Arsenal Filter] : This menu is a work in progress (WIP) and may not be finished.';
							findDisplay 49 closeDisplay 0;
							findDisplay -1 closeDisplay 0;
							disableSerialization;
							with uiNamespace do 
							{
								createDialog 'RscDisplayEmpty';showChat true;
								showChat true;
								_d = findDisplay -1;
								_display = _d;
								_bkCtrl = _display ctrlCreate ['IGUIBack',-1];
								_bkCtrl ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.304219 * safezoneW,0.418 * safezoneH];
								_bkCtrl ctrlSetBackgroundColor [0,0.1,0,0.75];
								_bkCtrl ctrlCommit 0;
								_bkCtrl = _display ctrlCreate ['IGUIBack',-1];
								_bkCtrl ctrlSetPosition [0.298906 * safezoneW + safezoneX,0.665 * safezoneH + safezoneY,0.304219 * safezoneW,0.099 * safezoneH];
								_bkCtrl ctrlSetBackgroundColor [0,0.1,0,0.75];
								_bkCtrl ctrlCommit 0;
								_bkCtrl = _display ctrlCreate ['IGUIBack',-1];
								_bkCtrl ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.236 * safezoneH + safezoneY,0.0928125 * safezoneW,0.165 * safezoneH];
								_bkCtrl ctrlSetBackgroundColor [0,0.1,0,0.75];
								_bkCtrl ctrlCommit 0;
								_bkCtrl = _display ctrlCreate ['IGUIBack',-1];
								_bkCtrl ctrlSetPosition [0.608281 * safezoneW + safezoneX,0.412 * safezoneH + safezoneY,0.0928125 * safezoneW,0.352 * safezoneH];
								_bkCtrl ctrlSetBackgroundColor [0,0.1,0,0.75];
								_bkCtrl ctrlCommit 0;
								_bkCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_bkCtrl ctrlSetPosition [0.371094 * safezoneW + safezoneX,0.73 * safezoneH + safezoneY,0.159844 * safezoneW,0.033 * safezoneH];
								_bkCtrl ctrlSetStructuredText parseText ("<t valign='middle' color='ffffff' align='center' font='EtelISFonospaceProBold' shadow='2' size='" + (str ((safeZoneH * 0.5) * 0.7)) + "'><img image='\A3\ui_f\data\igui\RscCustomInfo\north_ca.paa'></img> EXPORT <img image='\A3\ui_f\data\igui\RscCustomInfo\north_ca.paa'></img></t>");
								_bkCtrl ctrlSetBackgroundColor [0,0,0,0];
								_bkCtrl ctrlEnable false;
								_bkCtrl ctrlSetFade 0;
								_bkCtrl ctrlCommit 0;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 2.2)) + "'><img image='\A3\ui_f\data\logos\arsenal_1024_ca.paa'></img> Manual Blacklist</t>");
								_titleCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.247 * safezoneH + safezoneY,0.293906 * safezoneW,0.044 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [0,0,0,0];
								_titleCtrl ctrlCommit 0;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='left' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>Blacklisted Weapons:</t>");
								_titleCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.293906 * safezoneW,0.022 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [-1,-1,-1,0.6];
								_titleCtrl ctrlCommit 0;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='left' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>Blacklisted Magazines:</t>");
								_titleCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.293906 * safezoneW,0.022 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [-1,-1,-1,0.6];
								_titleCtrl ctrlCommit 0;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='left' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>Blacklisted Items:</t>");
								_titleCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.478 * safezoneH + safezoneY,0.293906 * safezoneW,0.022 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [-1,-1,-1,0.6];
								_titleCtrl ctrlCommit 0;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='left' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1)) + "'>Blacklisted Backpacks:</t>");
								_titleCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.566 * safezoneH + safezoneY,0.293906 * safezoneW,0.022 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [-1,-1,-1,0.6];
								_titleCtrl ctrlCommit 0;
								_weaponsCtrl = _display ctrlCreate ['RscEditMulti', -1];
								_weaponsCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_weaponsTxt', "['', '']"]);
								_weaponsCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.335 * safezoneH + safezoneY,0.293906 * safezoneW,0.044 * safezoneH];
								_weaponsCtrl ctrlCommit 0;
								_weaponsCtrl ctrlSetBackgroundColor [0,0,0,0.6];
								_weaponsCtrl ctrlSetTooltip "INPUT\nList of weapon classnames.\nFormat: ['', '']\nExample: ['arifle_AK12_GL_lush_F', 'hgun_P07_khk_F']";
								_display setVariable ['weapons', _weaponsCtrl];
								_magazinesCtrl = _display ctrlCreate ['RscEditMulti', -1];
								_magazinesCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_magazinesTxt', "['', '']"]);
								_magazinesCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.293906 * safezoneW,0.044 * safezoneH];
								_magazinesCtrl ctrlCommit 0;
								_magazinesCtrl ctrlSetBackgroundColor [0,0,0,0.6];
								_magazinesCtrl ctrlSetTooltip "INPUT\nList of magazine classnames.\nFormat: ['', '']\nExample: ['30Rnd_65x39_caseless_mag', '16Rnd_9x21_Mag']";
								_display setVariable ['magazines', _magazinesCtrl];
								_itemsCtrl = _display ctrlCreate ['RscEditMulti', -1];
								_itemsCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_itemsTxt', "['', '']"]);
								_itemsCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.511 * safezoneH + safezoneY,0.293906 * safezoneW,0.044 * safezoneH];
								_itemsCtrl ctrlCommit 0;
								_itemsCtrl ctrlSetBackgroundColor [0,0,0,0.6];
								_itemsCtrl ctrlSetTooltip "INPUT\nList of item classnames.\nFormat: ['', '']\nExample: ['FirstAidKit', 'bipod_01_F_blk']";
								_display setVariable ['items', _itemsCtrl];
								_backpacksCtrl = _display ctrlCreate ['RscEditMulti', -1];
								_backpacksCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_backpacksTxt', "['', '']"]);
								_backpacksCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.599 * safezoneH + safezoneY,0.293906 * safezoneW,0.044 * safezoneH];
								_backpacksCtrl ctrlSetBackgroundColor [0,0,0,0.6];
								_backpacksCtrl ctrlCommit 0;
								_backpacksCtrl ctrlSetTooltip "INPUT\nList of backpack classnames.\nFormat: ['', '']\nExample: ['B_Kitbag_mcamo', 'B_UGV_02_Demining_backpack_F']";
								_display setVariable ['backpacks', _backpacksCtrl];
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.1)) + "'>— Save Filter —</t>");
								_titleCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.247 * safezoneH + safezoneY,0.0825 * safezoneW,0.044 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [0,0,0,0];
								_titleCtrl ctrlSetFade 1;
								_titleCtrl ctrlCommit 0;
								_titleCtrl ctrlSetFade 0;
								_titleCtrl ctrlCommit 1;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 0.7)) + "'>Save As:</t>");
								_titleCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.302 * safezoneH + safezoneY,0.0825 * safezoneW,0.022 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [0,0,0,0];
								_titleCtrl ctrlSetFade 1;
								_titleCtrl ctrlCommit 0;
								_titleCtrl ctrlSetFade 0;
								_titleCtrl ctrlCommit 1;
								_nameCtrl = _display ctrlCreate ['RscEditMulti', -1];
								_nameCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_name', ""]);
								_nameCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.324 * safezoneH + safezoneY,0.0825 * safezoneW,0.022 * safezoneH];
								_nameCtrl ctrlSetTooltip 'Name of Blacklist';
								_nameCtrl ctrlSetBackgroundColor [0,0,0,0.6];
								_nameCtrl ctrlSetFade 1;
								_nameCtrl ctrlCommit 0;
								_nameCtrl ctrlSetFade 0;
								_nameCtrl ctrlCommit 1;
								_display setVariable ['name', _nameCtrl];
								_saveCtrl = _display ctrlCreate ['RscButtonMenu',-1];
								_saveCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.357 * safezoneH + safezoneY,0.0825 * safezoneW,0.033 * safezoneH];
								_saveCtrl ctrlSetTooltip 'Save the current input data on your profile';
								_saveCtrl ctrlSetBackgroundColor [0.5,0.5,0.5,0.75];
								_saveCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>SAVE</t>");
								_saveCtrl ctrlEnable false;
								_saveCtrl ctrladdEventHandler ["ButtonClick", 
								{
									params ["_control"];
									[_control] spawn 
									{
										params ["_control"];
										disableSerialization;
										with uiNamespace do 
										{
											private ['_parentDisplay', '_weaponsCtrl', '_magazinesCtrl', '_itemsCtrl', '_backpacksCtrl', '_nameCtrl', '_weapons', '_magazines', '_items', '_backpacks', '_name'];
											_parentDisplay = ctrlParent _control;
											_weaponsCtrl = _parentDisplay getVariable 'weapons';
											_magazinesCtrl = _parentDisplay getVariable 'magazines';
											_itemsCtrl = _parentDisplay getVariable 'items';
											_backpacksCtrl = _parentDisplay getVariable 'backpacks';
											_nameCtrl = _parentDisplay getVariable 'name';
											_weapons = [];
											_magazines = [];
											_items = [];
											_backpacks = [];
											_name = '';
											_weapons = call (compile (ctrlText _weaponsCtrl));
											_magazines = call (compile (ctrlText _magazinesCtrl));
											_items = call (compile (ctrlText _itemsCtrl));
											_backpacks = call (compile (ctrlText _backpacksCtrl));
											_name = ctrlText _nameCtrl;
											if (_name == '') exitWith {systemChat "ERROR: Name cannot be blank!";};
											_mySaves = profileNamespace getVariable ['JAM_arsenalFilters', ['', []]];
											_overwrite = false;
											_existingIndex = -1;
											{
												_saveName = _x # 0;
												_existingIndex = _forEachIndex;
												if (_saveName == _name) exitWith 
												{
													_overwrite = true;
												};
											} forEach _mySaves;
											if (_overwrite) then 
											{
												_mySaves deleteAt _existingIndex;
											};
											_variable = 
											[
												_name,
												[
													_weapons,
													_magazines,
													_items,
													_backpacks
												]
											];
											_mySaves pushBack _variable;
											profileNamespace setVariable ['JAM_arsenalFilters', _mySaves];
											saveProfileNamespace;
											_fnc_refreshLoadList = 
											{
												params [['_parentDisplay', displayNull]];
												disableSerialization;
												with uiNamespace do 
												{
													_mySaves = profileNamespace getVariable ['JAM_arsenalFilters', []];
													_saveCount = count _mySaves;
													_indexToSel = _saveCount - 1;
													if (_mySaves != 0) then 
													{
														lbClear _listCtrl;
														{
															_thisSave = _x;
															_saveName = _thisSave # 0;
															_saveData = _thisSave # 1;
															_idx = _listCtrl lbAdd _saveName;
															_listCtrl lbSetData [_idx, str _saveData];
															_listCtrl lbSetPicture [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\box_ca.paa"];
															_listCtrl lbSetPictureRight [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa"];
															_listCtrl lbSetTooltip [_idx, format ["%1\n(Saved to profile [ %1 ])", _saveName, profileName]];
														} forEach _mySaves;
														_listCtrl lbSetCurSel _indexToSel;
														_listCtrl ctrlCommit 0;
													};
												};
											};
											[_parentDisplay] call _fnc_refreshLoadList;
											playSound 'click';
										};
									};
								}];
								_saveCtrl ctrlSetFade 1;
								_saveCtrl ctrlCommit 0;
								_saveCtrl ctrlSetFade 0;
								_saveCtrl ctrlCommit 1;
								_titleCtrl = _display ctrlCreate ['RscStructuredText',-1];
								_titleCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.1)) + "'>— Load Filter —</t>");
								_titleCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.0825 * safezoneW,0.044 * safezoneH];
								_titleCtrl ctrlSetBackgroundColor [0,0,0,0];
								_titleCtrl ctrlSetFade 1;
								_titleCtrl ctrlCommit 0;
								_titleCtrl ctrlSetFade 0;
								_titleCtrl ctrlCommit 1;
								_listCtrl = _display ctrlCreate ['RscListBox', -1];
								_listCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.478 * safezoneH + safezoneY,0.0825 * safezoneW,0.187 * safezoneH];
								_mySaves = profileNamespace getVariable ['JAM_arsenalFilters', []];
								if (count _mySaves != 0) then 
								{
									{
										_thisSave = _x;
										_saveName = _thisSave # 0;
										_saveData = _thisSave # 1;
										_idx = _listCtrl lbAdd _saveName;
										_listCtrl lbSetData [_idx, str _saveData];
										_listCtrl lbSetPicture [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\box_ca.paa"];
										_listCtrl lbSetPictureRight [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa"];
										_listCtrl lbSetTooltip [_idx, format ["%1\n(Saved to profile [ %1 ])", _saveName, profileName]];
									} forEach _mySaves;
								} else 
								{
									{
										_saveName = _x;
										_saveData = '';
										_idx = _listCtrl lbAdd _saveName;
										_listCtrl lbSetData [_idx, _saveData];
										_listCtrl lbSetPicture [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\box_ca.paa"];
										_listCtrl lbSetPictureRight [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa"];
										_listCtrl lbSetTooltip [_idx, format ["%1", _saveName, profileName]];
									} forEach 
									[
										'“Blacklist 01”',
										'“Blacklist 02”',
										'“Blacklist 03”',
										'“Blacklist 04”',
										'“Blacklist 05”',
										'“Blacklist 06”',
										'“Blacklist 07”'
									];
								};
								_listCtrl lbSetCurSel 0;
								_listCtrl ctrlSetFade 1;
								_listCtrl ctrlCommit 0;
								_listCtrl ctrlSetFade 0;
								_listCtrl ctrlCommit 1;
								_display setVariable ['list', _listCtrl];
								_loadCtrl = _display ctrlCreate ['RscButtonMenu',-1];
								_loadCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.676 * safezoneH + safezoneY,0.0825 * safezoneW,0.033 * safezoneH];
								_loadCtrl ctrlSetBackgroundColor [0,0,0.5,0.75];
								_loadCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>LOAD</t>");
								_loadCtrl ctrlSetTooltip 'Load the selected blacklist data onto the menu.\nPress APPLY to enable it.';
								_loadCtrl ctrlEnable false;
								_loadCtrl ctrladdEventHandler ["ButtonClick", 
								{
									params ["_control"];
									[_control] spawn 
									{
										params ["_control"];
										disableSerialization;
										with uiNamespace do 
										{
											private ['_parentDisplay', '_weaponsCtrl', '_magazinesCtrl', '_itemsCtrl', '_backpacksCtrl', '_nameCtrl', '_weapons', '_magazines', '_items', '_backpacks', '_name', '_listCtrl'];
											_parentDisplay = ctrlParent _control;
											_weaponsCtrl = _parentDisplay getVariable 'weapons';
											_magazinesCtrl = _parentDisplay getVariable 'magazines';
											_itemsCtrl = _parentDisplay getVariable 'items';
											_backpacksCtrl = _parentDisplay getVariable 'backpacks';
											_nameCtrl = _parentDisplay getVariable 'name';
											_listCtrl = _parentDisplay getVariable 'list';
											_weapons = [];
											_magazines = [];
											_items = [];
											_backpacks = [];
											_name = '';
											_data = [];
											_dataStr = '[]';
											_filterData = [];
											_index = lbCurSel _listCtrl;
											_dataStr = _listCtrl lbData _index;
											_data = call (compile _dataStr);
											_name = _data # 0;
											_filterData = _data # 1;
											_weapons = _filterData # 0;
											_magazines = _filterData # 1;
											_items = _filterData # 2;
											_backpacks = _filterData # 3;
											_nameCtrl ctrlSetText _name;
											_nameCtrl ctrlCommit 0;
											_weaponsCtrl ctrlSetText str _weapons;
											_weaponsCtrl ctrlCommit 0;
											_magazinesCtrl ctrlSetText str _magazines;
											_magazinesCtrl ctrlCommit 0;
											_itemsCtrl ctrlSetText str _items;
											_itemsCtrl ctrlCommit 0;
											_backpacksCtrl ctrlSetText str _backpacks;
											_backpacksCtrl ctrlCommit 0;
											playSound 'click';
										};
									};
								}];
								_loadCtrl ctrlSetFade 1;
								_loadCtrl ctrlCommit 0;
								_loadCtrl ctrlSetFade 0;
								_loadCtrl ctrlCommit 1;
								_deleteCtrl = _display ctrlCreate ['RscButtonMenu',-1];
								_deleteCtrl ctrlSetPosition [0.613437 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.0825 * safezoneW,0.033 * safezoneH];
								_deleteCtrl ctrlSetBackgroundColor [0.5,0,0,0.75];
								_deleteCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>DELETE</t>");
								_deleteCtrl ctrlSetTooltip 'Delete the selected blacklist data from your profile.';
								_deleteCtrl ctrlEnable false;
								_deleteCtrl ctrladdEventHandler ["ButtonClick", 
								{
									params ["_control"];
									[_control] spawn 
									{
										params ["_control"];
										disableSerialization;
										with uiNamespace do 
										{
											private ['_parentDisplay', '_weaponsCtrl', '_magazinesCtrl', '_itemsCtrl', '_backpacksCtrl', '_nameCtrl', '_weapons', '_magazines', '_items', '_backpacks', '_name', '_listCtrl'];
											_parentDisplay = ctrlParent _control;
											_listCtrl = _parentDisplay getVariable 'list';
											_weapons = [];
											_magazines = [];
											_items = [];
											_backpacks = [];
											_name = '';
											_data = [];
											_dataStr = '[]';
											_filterData = [];
											_index = lbCurSel _listCtrl;
											_dataStr = _listCtrl lbData _index;
											_data = call (compile _dataStr);
											_name = _data # 0;
											_mySaves = profileNamespace getVariable ['JAM_arsenalFilters', []];
											{
												_saveName = _x # 0;
												_existingIndex = _forEachIndex;
												if (_saveName == _name) exitWith 
												{
													_mySaves deleteAt _existingIndex;
												};
											} forEach _mySaves;
											profileNamespace setVariable ['JAM_arsenalFilters', _mySaves];
											saveProfileNamespace;
											_fnc_refreshLoadList = 
											{
												params [['_parentDisplay', displayNull]];
												disableSerialization;
												with uiNamespace do 
												{
													_mySaves = profileNamespace getVariable ['JAM_arsenalFilters', []];
													_saveCount = count _mySaves;
													_indexToSel = _saveCount - 1;
													if (_mySaves != 0) then 
													{
														lbClear _listCtrl;
														{
															_thisSave = _x;
															_saveName = _thisSave # 0;
															_saveData = _thisSave # 1;
															_idx = _listCtrl lbAdd _saveName;
															_listCtrl lbSetData [_idx, str _saveData];
															_listCtrl lbSetPicture [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\box_ca.paa"];
															_listCtrl lbSetPictureRight [_idx, "\A3\ui_f\data\IGUI\Cfg\simpleTasks\types\documents_ca.paa"];
															_listCtrl lbSetTooltip [_idx, format ["%1\n(Saved to profile [ %1 ])", _saveName, profileName]];
														} forEach _mySaves;
														_listCtrl lbSetCurSel _indexToSel;
														_listCtrl ctrlCommit 0;
													};
												};
											};
											[_parentDisplay] call _fnc_refreshLoadList;
											playSound 'click';
										};
									};
								}];
								_deleteCtrl ctrlSetFade 1;
								_deleteCtrl ctrlCommit 0;
								_deleteCtrl ctrlSetFade 0;
								_deleteCtrl ctrlCommit 1;
								_applyCtrl = _display ctrlCreate ['RscButtonMenu',-1];
								_applyCtrl ctrlSetPosition [0.536094 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.061875 * safezoneW,0.033 * safezoneH];
								_applyCtrl ctrlSetTooltip 'Apply & update the mission’s arsenal filter (blacklist data),\nusing the input data from this menu.\n* Arsenal Filter must be enabled *';
								_applyCtrl ctrlSetBackgroundColor [0,0,0,0.75];
								_applyCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>APPLY</t>");
								_applyCtrl ctrlEnable false;
								_applyCtrl ctrladdEventHandler ["ButtonClick", 
								{
									params ["_control"];
									[_control] spawn 
									{
										params ["_control"];
										disableSerialization;
										with uiNamespace do 
										{
											
											playSound 'click';
										};
									};
								}];
								_applyCtrl ctrlCommit 0;
								_cancelCtrl = _display ctrlCreate ['RscButtonMenu',-1];
								_cancelCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.72 * safezoneH + safezoneY,0.061875 * safezoneW,0.033 * safezoneH];
								_cancelCtrl ctrlSetTooltip 'Close menu.';
								_cancelCtrl ctrlSetBackgroundColor [0,0,0,0.75];
								_cancelCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>CANCEL</t>");
								_cancelCtrl ctrladdEventHandler ["ButtonClick", 
								{
									params ["_control"];
									[_control] spawn 
									{
										params ["_control"];
										disableSerialization;
										with uiNamespace do 
										{
											_parentDisplay = ctrlParent _control;
											_parentDisplay closeDisplay 0;
											playSound 'click';
										};
									};
								}];
								_cancelCtrl ctrlCommit 0;
								uiNamespace setVariable 
								[
									'JAM_gui_arsenalFilter_exportTxt', 
									format 
									[
										"
											[ %1, %2, %3, %4 ]
										",
										ctrlText _weaponsCtrl,
										ctrlText _magazinesCtrl,
										ctrlText _itemsCtrl,
										ctrlText _backpacksCtrl
									]
								];
								_exportCtrl = _display ctrlCreate ['RscEditMulti',-1];
								_exportCtrl ctrlSetText (uiNamespace getVariable ['JAM_gui_arsenalFilter_exportTxt', "[ [], [], [], [] ]"]);
								_exportCtrl ctrlSetPosition [0.304062 * safezoneW + safezoneX,0.676 * safezoneH + safezoneY,0.293906 * safezoneW,0.033 * safezoneH];
								_exportCtrl ctrlSetBackgroundColor [0.2,0.2,0.2,0.75];
								_exportCtrl ctrlSetTextColor [1,1,1,1];
								_exportCtrl ctrlSetTooltip 'OUTPUT\nCopy/paste & and save somewhere on your computer.\n(more reliable than saving to profile)';
								_exportCtrl ctrlCommit 0;
								_display setVariable ['export', _exportCtrl];
								[_display, _exportCtrl] spawn 
								{
									params ['_display', '_exportCtrl'];
									_weaponsCtrl = _display getVariable 'weapons';
									_magazinesCtrl = _display getVariable 'magazines';
									_itemsCtrl = _display getVariable 'items';
									_backpacksCtrl = _display getVariable 'backpacks';
									while {!isNull _display} do 
									{
										uiNamespace setVariable 
										[
											'JAM_gui_arsenalFilter_exportTxt', 
											format 
											[
												"[ %1, %2, %3, %4 ]",
												ctrlText _weaponsCtrl,
												ctrlText _magazinesCtrl,
												ctrlText _itemsCtrl,
												ctrlText _backpacksCtrl
											]
										];
										with uiNamespace do 
										{
											_exportCtrl ctrlSetText JAM_gui_arsenalFilter_exportTxt;
											_exportCtrl ctrlCommit 0;
										};
										uiSleep 0.1;
									};
								};
							};
						};
						[] spawn JAM_GUIfnc_openArsenalFilter_manual;
					};
				}];
				_manualCtrl ctrlCommit 0;
				_manualCtrl ctrlEnable false;
				
				_autoCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_autoCtrl ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.423 * safezoneH + safezoneY,0.139219 * safezoneW,0.044 * safezoneH];
				_autoCtrl ctrlSetTooltip 'Automatic configuration.\n(Remove items from the box to add them to blacklist)\nQuantity == INFINITE: Whitelist\nQuantity >= 0: Blacklist';
				_autoCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_autoCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.4)) + "'>AUTOMATIC<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 0.6)) + "'><br/>(Reference Arsenal)</t>");
				_autoCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
						comment 
						"
							whitelist format:
							
							[weapons, magazines, items, backpacks]
						";
						0=[] spawn 
						{
							"todo: account for non-whitelisted items looted (should not remove)";

							_notif = [] spawn 
							{
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["Creating blacklist reference arsenal..."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
								uiSleep 3;
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["Standby (do not do anything, just wait)..."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
							};

							systemChat format ['[Arsenal Filter] : Creating whitelist reference arsenal...'];
							systemChat format ['[Arsenal Filter] : Standby (do not do anything, just wait)...'];
							
							showChat true;
							_pos = getPos player;

							_thisArsenal = 'B_supplyCrate_F' createVehicleLocal  _pos;
							_thisArsenal setVariable ['JAM_isEditable', false, true];
							_thisArsenal allowDamage false;
							_thisArsenal hideObject true;
							_thisArsenal attachTo [vehicle player, [0,0,0]];

							clearWeaponCargoGlobal _thisArsenal;
							clearMagazineCargoGlobal _thisArsenal;
							clearItemCargoGlobal _thisArsenal;
							clearBackpackCargoGlobal _thisArsenal;
							
							private ['_weapons', '_magazines', '_items', '_backpacks'];
							_weapons = [];
							_magazines = [];
							_items = [];
							_backpacks = [];

							M9_arsenal_activeWhitelist = missionNamespace getVariable ['M9_arsenal_activeWhitelist', [[],[],[],[]]];
							_weapons = M9_arsenal_activeWhitelist # 0;
							_magazines = M9_arsenal_activeWhitelist # 1;
							_items = M9_arsenal_activeWhitelist # 2;
							_backpacks = M9_arsenal_activeWhitelist # 3;
							
							[ _thisArsenal, _weapons, true, true ] call BIS_fnc_addVirtualWeaponCargo;
							[ _thisArsenal, _magazines, true, true ] call BIS_fnc_addVirtualMagazineCargo;
							[ _thisArsenal, _items, true, true ] call BIS_fnc_addVirtualItemCargo;
							[ _thisArsenal, _backpacks, true, true ] call BIS_fnc_addVirtualBackpackCargo;
							
							systemChat format ['[Arsenal Filter] : Whitelist reference arsenal spawned.'];
							_notif = [] spawn 
							{
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["Whitelist reference arsenal spawned."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
							};
							

							_thisArsenal call BIS_fnc_showCuratorAttributes;
							showChat true;
							
							waitUntil {!isNull findDisplay -1};
							
							systemChat format ['[Arsenal Filter] : GUI opened.'];
							systemChat format ['[Arsenal Filter] : Equipment with the infinity symbol are whitelisted.'];
							
							disableSerialization;
							with uiNamespace do 
							{
								_display = findDisplay -1;
								_ctrl = _display displayCtrl 30003;
								_ctrlPos = ctrlPosition _ctrl;
								_ctrlPosX = _ctrlPos # 0;
								_ctrlPosY = _ctrlPos # 1;
								_ctrlPosW = _ctrlPos # 2;
								_ctrlPosH = _ctrlPos # 3;
								_ctrlPos = [_ctrlPosX - 0.015, _ctrlPosY + (-0.193), _ctrlPosW + 0.03, _ctrlPosH + (-0.58)];
								_ttile = _display ctrlCreate ["RscStructuredText", -1];
								_ttile ctrlSetPosition _ctrlPos;
								_ttile ctrlSetStructuredText parseText ("<t font='puristaBold' shadow='1' size='" + (str ((0.5 * safeZoneH) * 2)) + "' align='center'>— WHITELIST —<br/><t font='puristaMedium' shadow='2' size='" + (str ((0.5 * safeZoneH) * 1.6)) + "' align='center'>REFERENCE ARSENAL</t>");
								_ttile ctrlSetBackgroundColor [(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13]),(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54]),(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21]),(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])];
								_ttile ctrlCommit 0;
							};
							
							_notif = [] spawn 
							{
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["GUI opened. You may now tweak the whitelist."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
							};
							
							waitUntil {isNull findDisplay -1};
							
							systemChat format ['[Arsenal Filter] : Updating active filter (please wait)...'];
							showChat true;
							
							[] spawn 
							{
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["Updating active arsenal filter (please wait)..."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
							};
							
							_weapons = _thisArsenal call BIS_fnc_getVirtualWeaponCargo;
							_magazines = _thisArsenal call BIS_fnc_getVirtualMagazineCargo;
							_items = _thisArsenal call BIS_fnc_getVirtualItemCargo;
							_backpacks = _thisArsenal call BIS_fnc_getVirtualBackpackCargo;

							missionNamespace setVariable ['M9_arsenal_activeWhitelist', [
								_weapons,
								_magazines,
								_items,
								_backpacks
							], true];

							"
								To save, after updating, get the output of:
								M9_arsenal_activeWhitelist, 
								Then, save it somewhere on PC. 

								To load, you can manually update the whitelist by running:
								missionNamespace setVariable ['M9_arsenal_activeWhitelist', ..., true];

								Don't forget to enable the filter.
							";
							
							deleteVehicle _thisArsenal;
							
							systemChat format ['[Arsenal Filter] : Active filter updated.'];
							
							[] spawn 
							{
								_zeusLogic = objNull;
								_zeusLogic = getAssignedCuratorLogic player;
								if (isNull _zeusLogic) exitWith {};
								_feedbackText = format ["Active arsenal filter updated."];
								[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
							};
							showChat true;
						};
					};
				}];
				_autoCtrl ctrlCommit 0;
			};
		};
		M9SD_GUIfnc_arsenalFilter_main = 
		{
			findDisplay 49 closeDisplay 0;
			disableSerialization;
			with uiNamespace do 
			{
				createDialog 'RscDisplayEmpty';showChat true;
				showChat true;
				_display = findDisplay -1;
				
				_bkrnd = _display ctrlCreate ['IGUIBack', -1];
				comment "[(profilenamespace getvariable ['GUI_BCG_RGB_R',0.13]),(profilenamespace getvariable ['GUI_BCG_RGB_G',0.54]),(profilenamespace getvariable ['GUI_BCG_RGB_B',0.21]),(profilenamespace getvariable ['GUI_BCG_RGB_A',0.8])]";
				_bkrnd ctrlSetBackgroundColor [0, 0.1, 0, 0.7];
				_bkrnd ctrlSetPosition [0.432969 * safezoneW + safezoneX,0.28 * safezoneH + safezoneY,0.134062 * safezoneW,0.33 * safezoneH];
				_bkrnd ctrlCommit 0;
				
				
				_bkrnd = _display ctrlCreate ['RscStructuredText', -1];
				_bkrnd ctrlSetBackgroundColor [-1,-1,-1,0];
				_bkrnd ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.291 * safezoneH + safezoneY,0.12375 * safezoneW,0.033 * safezoneH];
				_bkrnd ctrlSetStructuredText parseText ("<t font='puristaBold' shadow='1' size='" + (str ((0.5 * safeZoneH) * 1.2)) + "' align='center'>— Arsenal Filter —</t>");
				_bkrnd ctrlCommit 0;

				_bkrndd = _display ctrlCreate ['RscStructuredText', -1];
				_bkrndd ctrlSetBackgroundColor [-1,-1,-1,0];
				_bkrndd ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.315 * safezoneH + safezoneY,0.12375 * safezoneW,0.033 * safezoneH];
				_bkrndd ctrlSetStructuredText parseText ("<t font='puristaSemiBold' shadow='1' size='" + (str ((0.5 * safeZoneH) * 0.64)) + "' align='center'><t color='#00a6ff'>by <t color='#00c9ff'>M9-SD</t>");
				_bkrndd ctrlSetFade 1;
				_bkrndd ctrlCommit 0;
				_bkrndd spawn {
					uisleep 0.5;
					_this ctrlSetFade 0;
					_this ctrlCommit 1;
				};
				_cancelCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_cancelCtrl ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.555 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
				_cancelCtrl ctrlSetTooltip 'Spawn a filtered arsenal limited to whitelisted items.';
				_cancelCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_cancelCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>SPAWN</t>");
				_cancelCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					if (False) then {
						[_control] spawn 
						{
							params ["_control"];
							disableSerialization;
							with uiNamespace do 
							{
								_parentDisplay = ctrlParent _control;
								_parentDisplay closeDisplay 0;
								playSound 'click';
							};
						};
					} else {
						
						private _pos = screentoworld getMousePosition;
						private _thisArsenal = createVehicle ["B_supplyCrate_F", _pos, [], 0, "NONE"];
						_thisArsenal allowDamage false;

						clearWeaponCargoGlobal _thisArsenal;
						clearMagazineCargoGlobal _thisArsenal;
						clearItemCargoGlobal _thisArsenal;
						clearBackpackCargoGlobal _thisArsenal;
						
						private ['_weapons', '_magazines', '_items', '_backpacks'];
						_weapons = [];
						_magazines = [];
						_items = [];
						_backpacks = [];

						M9_arsenal_activeWhitelist = missionNamespace getVariable ['M9_arsenal_activeWhitelist', [[],[],[],[]]];
						_weapons = M9_arsenal_activeWhitelist # 0;
						_magazines = M9_arsenal_activeWhitelist # 1;
						_items = M9_arsenal_activeWhitelist # 2;
						_backpacks = M9_arsenal_activeWhitelist # 3;
						
						[ _thisArsenal, _weapons, true, true ] call BIS_fnc_addVirtualWeaponCargo;
						[ _thisArsenal, _magazines, true, true ] call BIS_fnc_addVirtualMagazineCargo;
						[ _thisArsenal, _items, true, true ] call BIS_fnc_addVirtualItemCargo;
						[ _thisArsenal, _backpacks, true, true ] call BIS_fnc_addVirtualBackpackCargo;

						{[_x, [[_thisArsenal], true]] remoteExec ['addCuratorEditableObjects', 2]} foreach allcurators;

						systemChat format ['[Arsenal Filter] : Limited arsenal spawned.'];

						[_control] spawn 
						{
							params ["_control"];
							disableSerialization;
							with uiNamespace do 
							{
								_parentDisplay = ctrlParent _control;
								_parentDisplay closeDisplay 0;
								playSound 'click';
							};
						};
					};
				}];
				_cancelCtrl ctrlCommit 0;
				
				
				
				
				_resetCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_resetCtrl ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.5 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
				_resetCtrl ctrlSetTooltip 'Clear the whitelist.\nUpdates the active arsenal filter to default:\nALL ITEMS ALLOWED';
				_resetCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_resetCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>RESET</t>");
				_resetCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
					};
					missionNamespace setVariable ['M9_arsenal_activeWhitelist', [[], [], [], []], true];
					[[], 'RE2_M9SD_fnc_disableArsenalFilter', 0, 'M9SD_JIP_toggleArsenalFilter'] call M9SD_fnc_RE2_V4;
					systemChat '[Arsenal Filter] : Active whitelist reset and disabled.';
					_zeusLogic = objNull;
					_zeusLogic = getAssignedCuratorLogic player;
					if (isNull _zeusLogic) exitWith {};
					_feedbackText = format ["Arsenal filter/whitelist reset/disabled."];
					[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
				}];
				_resetCtrl ctrlCommit 0;
				

				_updateCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_updateCtrl ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.445 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
				_updateCtrl ctrlSetTooltip 'Update the whitelist.\nUpdates the active arsenal filter.\nDOES NOT ENABLE/DISABLE';
				_updateCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_updateCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaMedium' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>UPDATE</t>");
				_updateCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
							[] spawn (missionNamespace getVariable ['M9SD_GUIfnc_openArsenalFilterInputMethod', {}]);
						};
					};
					
					_zeusLogic = objNull;
					_zeusLogic = getAssignedCuratorLogic player;
					if (isNull _zeusLogic) exitWith {};
					_feedbackText = format ["Select update/input method:"];
					[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
				}];
				
				_updateCtrl ctrlCommit 0;
				
				
				
				_disableCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_disableCtrl ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.39 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
				_disableCtrl ctrlSetTooltip 'Turn off the whitelist.\nDisables the active arsenal filter.\nDOES NOT RESET FILTER DATA';
				_disableCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_disableCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>DISABLE</t>");
				_disableCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
					};
					[[], 'RE2_M9SD_fnc_disableArsenalFilter', 0, 'M9SD_JIP_toggleArsenalFilter'] call M9SD_fnc_RE2_V4;
					systemChat '[Arsenal Filter] : Disabled.';
					_zeusLogic = objNull;
					_zeusLogic = getAssignedCuratorLogic player;
					if (isNull _zeusLogic) exitWith {};
					_feedbackText = format ["Arsenal filter/whitelist DISABLED!"];
					[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;
				}];
				_disableCtrl ctrlCommit 0;
				
				

				_enableCtrl = _display ctrlCreate ['RscButtonMenu',-1];
				_enableCtrl ctrlSetPosition [0.438125 * safezoneW + safezoneX,0.335 * safezoneH + safezoneY,0.12375 * safezoneW,0.044 * safezoneH];
				_enableCtrl ctrlSetTooltip 'Turn on the whitelist.\nEnables the active arsenal filter.\nUPDATE FILTER DATA FIRST';
				_enableCtrl ctrlSetBackgroundColor [0,0,0,0.75];
				_enableCtrl ctrlSetStructuredText parseText ("<t valign='middle' align='center' font='PuristaLight' shadow='2' size='" + (str ((safeZoneH * 0.5) * 1.5)) + "'>ENABLE</t>");
				_enableCtrl ctrladdEventHandler ["ButtonClick", 
				{
					params ["_control"];
					[_control] spawn 
					{
						params ["_control"];
						disableSerialization;
						with uiNamespace do 
						{
							_parentDisplay = ctrlParent _control;
							_parentDisplay closeDisplay 0;
							playSound 'click';
						};
					};

					[[], 'RE2_M9SD_fnc_enableArsenalFilter', 0, 'M9SD_JIP_toggleArsenalFilter'] call M9SD_fnc_RE2_V4;
					
					systemChat '[Arsenal Filter] : Enabled.';
					_zeusLogic = objNull;
					_zeusLogic = getAssignedCuratorLogic player;
					if (isNull _zeusLogic) exitWith {};
					_feedbackText = format ["Arsenal filter/whitelist ENABLED!"];
					[_zeusLogic, _feedbackText] call BIS_fnc_showCuratorFeedbackMessage;

				}];
				_enableCtrl ctrlCommit 0;
			};
		};
		[] spawn M9SD_GUIfnc_arsenalFilter_main;
	};

	call M9SD_fnc_moduleCompDynamicArsenalFilter;
};


