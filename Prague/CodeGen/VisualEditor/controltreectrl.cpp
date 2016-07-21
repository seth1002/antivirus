// Machine generated IDispatch wrapper class(es) created by Microsoft Visual C++

// NOTE: Do not modify the contents of this file.  If this class is regenerated by
//  Microsoft Visual C++, your modifications will be overwritten.


#include "stdafx.h"
#include "controltreectrl.h"

/////////////////////////////////////////////////////////////////////////////
// CControlTreeCtrl

IMPLEMENT_DYNCREATE(CControlTreeCtrl, CWnd)

/////////////////////////////////////////////////////////////////////////////
// CControlTreeCtrl properties

short CControlTreeCtrl::GetBorderStyle()
{
	short result;
	GetProperty(DISPID_BORDERSTYLE, VT_I2, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetBorderStyle(short propVal)
{
	SetProperty(DISPID_BORDERSTYLE, VT_I2, propVal);
}

short CControlTreeCtrl::GetAppearance()
{
	short result;
	GetProperty(DISPID_APPEARANCE, VT_I2, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetAppearance(short propVal)
{
	SetProperty(DISPID_APPEARANCE, VT_I2, propVal);
}

BOOL CControlTreeCtrl::GetShowSelectionAlways()
{
	BOOL result;
	GetProperty(0x1, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetShowSelectionAlways(BOOL propVal)
{
	SetProperty(0x1, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetKeepExpandingStatus()
{
	BOOL result;
	GetProperty(0x2, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetKeepExpandingStatus(BOOL propVal)
{
	SetProperty(0x2, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetEnableChangeItemsState()
{
	BOOL result;
	GetProperty(0x3, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetEnableChangeItemsState(BOOL propVal)
{
	SetProperty(0x3, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetEnableOperationsOnDisabledItems()
{
	BOOL result;
	GetProperty(0xb, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetEnableOperationsOnDisabledItems(BOOL propVal)
{
	SetProperty(0xb, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetSaveExpandingStatus()
{
	BOOL result;
	GetProperty(0xc, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetSaveExpandingStatus(BOOL propVal)
{
	SetProperty(0xc, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetExpandSimpleLabelOnStart()
{
	BOOL result;
	GetProperty(0xf, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetExpandSimpleLabelOnStart(BOOL propVal)
{
	SetProperty(0xf, VT_BOOL, propVal);
}

BOOL CControlTreeCtrl::GetExpandCheckableItemOnCheck()
{
	BOOL result;
	GetProperty(0x10, VT_BOOL, (void*)&result);
	return result;
}

void CControlTreeCtrl::SetExpandCheckableItemOnCheck(BOOL propVal)
{
	SetProperty(0x10, VT_BOOL, propVal);
}

/////////////////////////////////////////////////////////////////////////////
// CControlTreeCtrl operations

SCODE CControlTreeCtrl::InitControl()
{
	SCODE result;
	InvokeHelper(0x4, DISPATCH_METHOD, VT_ERROR, (void*)&result, NULL);
	return result;
}

SCODE CControlTreeCtrl::SetPropertyTree(long hTree, long bRootIncluded)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4 VTS_I4;
	InvokeHelper(0x5, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hTree, bRootIncluded);
	return result;
}

SCODE CControlTreeCtrl::PurposeToChangeTree(long hNodeData)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4;
	InvokeHelper(0x6, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hNodeData);
	return result;
}

SCODE CControlTreeCtrl::SetPropertyTreeEnabled(long bEnable)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4;
	InvokeHelper(0x7, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		bEnable);
	return result;
}

SCODE CControlTreeCtrl::MergeDataTreeAndPattern(long hTreeData, long hPatternData, long* phResultData)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4 VTS_I4 VTS_PI4;
	InvokeHelper(0x8, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hTreeData, hPatternData, phResultData);
	return result;
}

SCODE CControlTreeCtrl::ExtractValuesDataTree(long hTreeData, long* phResultData, long* pPropInclude)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4 VTS_PI4 VTS_PI4;
	InvokeHelper(0x9, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hTreeData, phResultData, pPropInclude);
	return result;
}

SCODE CControlTreeCtrl::ChangeDisplayStrings()
{
	SCODE result;
	InvokeHelper(0xa, DISPATCH_METHOD, VT_ERROR, (void*)&result, NULL);
	return result;
}

SCODE CControlTreeCtrl::ExtractExpandingStatus(long hTreeData, long* phResultData)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4 VTS_PI4;
	InvokeHelper(0xd, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hTreeData, phResultData);
	return result;
}

SCODE CControlTreeCtrl::MergeDataTreeAndExpandingStatus(long hTreeData, long hStatusData)
{
	SCODE result;
	static BYTE parms[] =
		VTS_I4 VTS_I4;
	InvokeHelper(0xe, DISPATCH_METHOD, VT_ERROR, (void*)&result, parms,
		hTreeData, hStatusData);
	return result;
}