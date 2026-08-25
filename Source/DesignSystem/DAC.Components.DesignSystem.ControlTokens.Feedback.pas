unit DAC.Components.DesignSystem.ControlTokens.Feedback;

{ Responsabilidade: tokens de design system para feedbacks. }

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACFeedbackTokens = record
    BadgeDefaultWidth: Single;
    BadgeDefaultHeight: Single;
    ToastDefaultWidth: Single;
    ToastDefaultHeight: Single;
    ModalDefaultWidth: Single;
    ModalDefaultHeight: Single;
    TooltipDefaultWidth: Single;
    TooltipDefaultHeight: Single;
    LoadingDefaultWidth: Single;
    LoadingDefaultHeight: Single;
    ProgressDefaultWidth: Single;
    ProgressDefaultHeight: Single;
    StatusBarDefaultWidth: Single;
    StatusBarHeight: Single;
    StatusBarInset: Single;
    StatusBarRadius: Single;
    StatusBarIndicatorRadius: Single;
    StatusBarTextSize: Single;
    StatusBarTextBaseline: Single;
    StatusBarLeftTextOffset: Single;
    StatusBarRightTextInset: Single;
    ProgressLinearThickness: Single;
    ProgressCircularThickness: Single;
    ProgressValueTextSize: Single;
    ProgressValueTextInset: Single;
    ProgressValueTextOffset: Single;
    ProgressDisabledAlpha: Byte;
    LoadingTimerInterval: Integer;
    LoadingSpinnerInset: Single;
    LoadingSpinnerThickness: Single;
    LoadingDotsRadius: Single;
    LoadingDotsSpacing: Single;
    LoadingDotsInactiveAlpha: Byte;
    LoadingSpinnerTrackAlpha: Byte;
    LoadingDisabledAlpha: Byte;
    LoadingSkeletonAvatarTop: Single;
    LoadingSkeletonAvatarWidth: Single;
    LoadingSkeletonAvatarHeight: Single;
    LoadingSkeletonAvatarRadius: Single;
    LoadingSkeletonTextLeft: Single;
    LoadingSkeletonTitleTop: Single;
    LoadingSkeletonTitleHeight: Single;
    LoadingSkeletonLineTop: Single;
    LoadingSkeletonLineRightInset: Single;
    LoadingSkeletonLineHeight: Single;
    LoadingSkeletonRadius: Single;
    LoadingSkeletonHighlightWidth: Single;
    LoadingSkeletonHighlightAlpha: Byte;
    ToastRadius: Single;
    ToastBorderWidth: Single;
    ToastBorderAlpha: Byte;
    ToastIndicatorX: Single;
    ToastIndicatorRadius: Single;
    ToastTitleX: Single;
    ToastTitleBaseline: Single;
    ToastMessageBaseline: Single;
    ToastTitleTextSize: Single;
    ToastMessageTextSize: Single;
    ToastTextRightInset: Single;
    TooltipRadius: Single;
    TooltipBorderWidth: Single;
    TooltipBackgroundAlpha: Byte;
    TooltipBorderAlpha: Byte;
    TooltipTextInsetHorizontal: Single;
    TooltipTextInsetVertical: Single;
    TooltipTextSize: Single;
    TooltipOffset: Single;
    BadgeRadius: Single;
    BadgePadding: Single;
    BadgePillPadding: Single;
    BadgeIconSize: Single;
    BadgePillIconSize: Single;
    BadgeIconGap: Single;
    BadgeBorderAlpha: Byte;
    BadgeOutlineBorderAlpha: Byte;
    BadgeDisabledAlpha: Byte;
    BadgeCloseHoverAlpha: Byte;
    BadgeCloseInset: Single;
    SystemTextPrimary: TAlphaColor;
    SystemTextSecondary: TAlphaColor;
    SystemTextMuted: TAlphaColor;
    SystemTextAccent: TAlphaColor;
    SystemTextSuccess: TAlphaColor;
    SystemTextWarning: TAlphaColor;
    SystemTextDanger: TAlphaColor;
    Success: TAlphaColor;
    Error: TAlphaColor;
    StatusBackground: TAlphaColor;
    StatusBorder: TAlphaColor;
    StatusIndicator: TAlphaColor;
    StatusText: TAlphaColor;
    StatusTextSecondary: TAlphaColor;
    ProgressTrack: TAlphaColor;
    ProgressValueText: TAlphaColor;
    ProgressWarning: TAlphaColor;
    ProgressDanger: TAlphaColor;
    ProgressInfo: TAlphaColor;
    ProgressNeutral: TAlphaColor;
    LoadingSpinnerTrack: TAlphaColor;
    LoadingAccent: TAlphaColor;
    LoadingSkeletonBase: TAlphaColor;
    LoadingSkeletonHighlight: TAlphaColor;
    ToastSuccessBackground: TAlphaColor;
    ToastWarningBackground: TAlphaColor;
    ToastDangerBackground: TAlphaColor;
    ToastInfoBackground: TAlphaColor;
    ToastNeutralBackground: TAlphaColor;
    ToastSuccessBorder: TAlphaColor;
    ToastWarningBorder: TAlphaColor;
    ToastDangerBorder: TAlphaColor;
    ToastInfoBorder: TAlphaColor;
    ToastNeutralBorder: TAlphaColor;
    FeedbackText: TAlphaColor;
    TooltipBackground: TAlphaColor;
    TooltipBorder: TAlphaColor;
    TooltipText: TAlphaColor;
    BadgeSoftBackground: TAlphaColor;
    BadgeOutlineBackground: TAlphaColor;
    BadgeBorder: TAlphaColor;
    BadgeText: TAlphaColor;
  end;

implementation

end.
