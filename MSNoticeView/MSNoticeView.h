//
//  MSNoticeView.h
//  TipsView
//
//  Created by ypl on 2018/12/28.
//  Copyright © 2018年 ypl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MSNoticeView : UIView

typedef  void (^NoticeViewClickBlock)(NSString *msg);

/**
 *  显示消息
 *
 *  @param msg        消息内容
 *  @param detailMsg  消息明细
 *  @param color      消息视图的的背景颜色
 *  @param clickBlock 点击操作的代码块
 */
+(void)showSuccess:(NSString *)msg detail:(NSString *)detailMsg  hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock;

/**
 *  显示消息
 *
 *  @param msg        消息内容
 *  @param detailMsg  消息明细
 *  @param color      消息视图的的背景颜色
 *  @param clickBlock 点击操作的代码块
 */
+(void)showError:(NSString *)msg detail:(NSString *)detailMsg  hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock;
/**
 *  显示消息
 *
 *  @param msg    消息内容
 *  @param action 点击消息后的操作
 *  @param target 点击操作所属的对象
 *  @param color  消息视图的的背景颜色
 */
+(void)showMessage:(NSString *)msg detail:(NSString *)detailMsg action:(SEL) action target:(id)target hudColor:(UIColor *)color;

/**
 *  显示消息
 *
 *  @param msg        消息内容
 *  @param color      消息视图的的背景颜色
 *  @param clickBlock 点击操作的代码块
 */
+(void)showMessage:(NSString *)msg detail:(NSString *)detailMsg hudColor:(UIColor *)color clickBlock:(NoticeViewClickBlock)clickBlock;

/**
 *  取消显示
 */
+(void)dismiss;
@end
