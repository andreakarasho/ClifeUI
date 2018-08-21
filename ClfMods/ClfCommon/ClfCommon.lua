
LoadResources( "./UserInterface/"..SystemData.Settings.Interface.customUiName.."/ClfMods/ClfCommon", "ClfIcons.xml", "ClfIcons.xml" )
LoadResources( "./UserInterface/"..SystemData.Settings.Interface.customUiName.."/ClfMods/ClfCommon", "ClfTextures.xml", "ClfTextures.xml" )


ClfCommon = {}

function _void() end

function _return_false() return false end

function _return_true() return true end


function ClfCommon.initialize()
	ClfUtil.initialize()
	ClfSettings.initialize()
	ClfReActionsWindow.initialize()
	ClfRefactor.initialize()
end


function ClfCommon.onUpdate( timePassed )
	local pcall = pcall
	pcall( ClfActions.onUpdate, timePassed )
	pcall( ClfDamageMod.onUpdate, timePassed )

	pcall( ClfCommon.processListenersCheck )
end



local CheckListeners = {}


function ClfCommon.processListenersCheck()
	local CheckListeners = CheckListeners
	local now = Interface.TimeSinceLogin
	for name, listener in pairs( CheckListeners ) do
		if ( listener.begin and listener.begin > now ) then
			continue
		end

		local ok, success = pcall( listener.check )

		if ( success and ok ) then
			pcall( listener.done, name )

			if ( listener.remove ) then
				CheckListeners[ name ] = nil
			end
		elseif ( listener.limit <= now ) then
			if ( listener.fail ) then
				pcall( listener.fail, name )
			end
			CheckListeners[ name ] = nil
		end
	end
end


--[[
** onUpdate���Ƃɔ��肷��I�u�W�F�N�g��o�^
* @param  {string} name      �K�{�F�I�u�W�F�N�g�̃L�[�ɂȂ閼�O
* @param  {table}  listener  �K�{�F
*         ����A�����A���s���Ɏ��s����֐���A�I�����ɃI�u�W�F�N�g����菜�����A����̒x���A���~�b�g���ԁi�b�j���܂߂�table
*         e.g. listener = {
*                 check  = function() { return exp },			-- �K�{�F����p�֐�
*                 done   = function() {  },						-- �K�{�F����p�֐�����^���Ԃ�������s����֐�
*                 fail   = function() {  },						-- limit �܂łɔ��肪�������Ȃ��������Ɏ��s
*                 begin  = Interface.TimeSinceLogin + 1,		-- �����画��J�n���邩�B�w�肵�Ȃ���Ύ��̃v���Z�X����
*                 limit  = Interface.TimeSinceLogin + 10,	-- ���܂Ŕ��肷�邩�B�w�肵�Ȃ���� 10�b��܂�
*                 remove = true,										-- ���芮�����Ɏ�菜���B�w�肵�Ȃ���� true
*              }
]]
function ClfCommon.addCheckListener( name, listener )
	if ( not name
			or CheckListeners[ name ]
			or not listener
			or not listener.check
			or not listener.done
		) then
		return
	end

	listener.limit  = listener.limit or Interface.TimeSinceLogin + 10
	listener.remove = ( listener.remove == nil ) or not not listener.remove

	CheckListeners[ name ] = listener
end





