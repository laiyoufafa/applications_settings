/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import {PinSubType} from '../model/passwordImpl/PasswordModel';
import PasswordCheckController from '../controller/password/PasswordCheckController'
import Router from '@system.router';
import InputMethod from '@ohos.inputmethod';

let param;
const DEFAULT_TIMES = 5;

@Entry
@Component
struct PasswordCheck {
  private TAG_PAGE = ConfigData.TAG + 'PasswordCheck page ';
  private mController: PasswordCheckController = new PasswordCheckController()

// bind Properties
  private pinToken: string = undefined
  @State @Watch("freezeView") private freezingTime: number = 0
  @State @Watch("updateView") private remainTimes: number = -1

// handler
  private passwordOnChangeHandler: (value: string) => void;
  private okOnClickHandler: (event?: ClickEvent) => void;

// private Properties
  private pageRequestCode: number = -1
  private prevPageUri: string = undefined
  private pinChallenge: string = undefined
  @State private passwordType: number = -1
  @State private promptMessage: string | Resource = ''
  @State private buttonVisibility: Visibility = Visibility.Visible
  @State private freezingTimeForView: number = -1;
  @State private password: string = ''
  private timerId: number = -1
  @State isTouchedLeft: boolean = false
  @State isTouchedRight: boolean = false

  @Log
  aboutToAppear(): void {

    this.getRouterParam();

    // bind event handlers
    this.passwordOnChangeHandler = this.mController.passwordOnChange.bind(this.mController);
    this.okOnClickHandler = this.mController.inputFinish.bind(this.mController);

    // bind component and initialize
    this.mController.bindComponent(this)
      .bindProperties(["freezingTime", "remainTimes", "pinToken"])
      .initData()
      .subscribe();

    this.updateView();
  }

  @Log
  aboutToDisappear(): void {
    this.mController.unsubscribe();
    this.stopCountDown();
  }

/**
   * Get the params from router
   */
  @Log
  getRouterParam() {
    param = Router.getParams()
    if (!param) {
      return;
    }
    this.pageRequestCode = param.pageRequestCode;
    this.prevPageUri = param.prevPageUri;
    this.pinChallenge = param.pinChallenge;
    this.passwordType = param.passwordType;
  }

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            // head
            HeadComponent({ headName: $r('app.string.password_enter_password'), isActive: true })

            // freeze view
            if (this.freezingTimeForView > 0) {

              Row() {
                // attempt seconds
                Text($r('app.string.password_remain_times', this.freezingTimeForView))
                  .fontSize($r('app.float.font_28'))
                  .fontColor(Color.Blue)
                  .textCase(TextCase.UpperCase)
                  .margin({ top: $r('app.float.password_input_message_vertical_margin'), bottom: $r('app.float.password_input_message_vertical_margin') })
                  .padding({ left: $r('app.float.item_common_horizontal_margin'), right: $r('app.float.item_common_horizontal_margin') })
                  .align(Alignment.Center)
              }
              .backgroundColor(Color.Gray)
              .margin({
                left: $r('app.float.password_count_down_view_vertical_margin'),
                right: $r('app.float.password_count_down_view_vertical_margin')
              })

              // input
            } else {
              Column() {
                // input message
                Text(' ')
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_foreground'))
                  .margin({ top: $r('app.float.item_common_horizontal_margin') })
                  .align(Alignment.Center)
                  .visibility(Visibility.Hidden)

                // input password
                Row() {
                  TextInput({ placeholder: '', text: this.password })
                    .placeholderFont({size: $r("app.float.font_18"), weight:FontWeight.Normal, style: FontStyle.Normal})
                    .type(InputType.Password)
                    .enterKeyType(EnterKeyType.Done)
                    .caretColor(Color.Blue)
                    .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})
                    .margin({ top: $r('app.float.wh_value_50') })
                    .height($r("app.float.wh_value_40"))
                    .layoutWeight(1)
                    .borderRadius(0)
                    .backgroundColor($r('app.color.color_00000000_transparent'))
                    .onChange(this.passwordOnChangeHandler)
                    .onSubmit((enterKey) => {
                      InputMethod.getInputMethodController().stopInput().then((ret) => {
                        LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
                      });
                    })
                }
                Divider()
                  .padding({left: $r('sys.float.ohos_id_card_margin_start'), right: $r('sys.float.ohos_id_card_margin_end')})

                // prompt message
                Text(this.promptMessage)
                  .fontSize($r('sys.float.ohos_id_text_size_body2'))
                  .fontWeight(FontWeight.Medium)
                  .fontColor($r('sys.color.ohos_id_color_warning'))
                  .align(Alignment.Center)
                  .textAlign(TextAlign.Center)
                  .margin({ top: $r('app.float.distance_14'), bottom: $r('app.float.distance_32') })

                // button
                Row() {
                  Text($r('app.string.cancel'))
                    .fontSize($r('app.float.application_button_subtitle_size'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .fontColor($r('app.color.font_color_007DFF'))
                    .textAlign(TextAlign.Center)
                    .layoutWeight(1)
                    .height($r('app.float.application_button_height'))
                    .borderRadius($r('app.float.radius_20'))
                    .backgroundColor(!this.isTouchedLeft ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
                    .onTouch((event: TouchEvent) => {
                      if (event.type === TouchType.Down) {
                        this.isTouchedLeft = true;
                      }
                      if (event.type === TouchType.Up) {
                        this.isTouchedLeft = false;
                      }
                    })
                    .onClick(() => {
                      Router.back();
                    })

                  Column()
                    .width( $r('app.float.distance_12'))
                    .height($r('app.float.application_button_height'))

                  Text( $r('app.string.next'))
                    .fontSize($r('app.float.application_button_subtitle_size'))
                    .lineHeight($r('app.float.wh_value_22'))
                    .fontColor($r('app.color.font_color_007DFF'))
                    .textAlign(TextAlign.Center)
                    .layoutWeight(1)
                    .height($r('app.float.application_button_height'))
                    .borderRadius($r('app.float.radius_20'))
                    .backgroundColor(!this.isTouchedRight ? $r("app.color.color_D8D8D8_grey") : $r("sys.color.ohos_id_color_foreground_contrary"))
                    .onTouch((event: TouchEvent) => {
                      if (event.type === TouchType.Down) {
                        this.isTouchedRight = true;
                      }
                      if (event.type === TouchType.Up) {
                        this.isTouchedRight = false;
                      }
                    })
                    .onClick(this.okOnClickHandler)
                }
                .alignItems(VerticalAlign.Center)
                .width(ConfigData.WH_100_100)
                .padding({
                  top: $r('app.float.distance_24'),
                  bottom: $r('app.float.distance_36'),
                  left: $r('app.float.distance_24'),
                  right: $r('app.float.distance_24')
                })
                .margin({ top: $r('app.float.distance_66') })
                .visibility(this.buttonVisibility)

              }
            }
          }
          .padding({left: $r('app.float.distance_24'), right: $r('app.float.distance_24')})
          .height(ConfigData.WH_100_100)
          .width(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

// --------------------------- updateView -----------------------
/**
   * Update view
   */
  @Log
  updateView() {
    this.promptMessage = this.getPromptMessage();
    this.buttonVisibility = this.getButtonVisibility();
  }

/**
   * Get prompt message
   *
   * @return : message
   */
  @Log
  getPromptMessage(): string | Resource {
    return (this.remainTimes > 0 && this.remainTimes < DEFAULT_TIMES) ? $r('app.string.password_message_incorrect', this.remainTimes) : '';
  }

/**
   * Get button visibility
   *
   * @return : button visibility
   */
  @Log
  getButtonVisibility(): Visibility {
    return this.passwordType == PinSubType.PIN_SIX ? Visibility.Hidden : Visibility.Visible
  }

/**
   * When freezing time is greater than 0, start count down view.
   *
   * @return : button visibility
   */
  @Log
  freezeView() {
    if (this.freezingTime <= 0) {
      this.stopCountDown()
      return;
    }
    this.freezingTimeForView = this.freezingTime / 1000;
    LogUtil.info(this.TAG_PAGE + `freezeView freezingTimeForView = ${this.freezingTimeForView}`);
    this.timerId = setInterval(() => {
      if (this.freezingTimeForView <= 0) {
        this.stopCountDown()
        this.timerId = -1
        this.freezingTimeForView = 0
        this.freezingTime = 0
        this.updateView()
      } else {
        this.freezingTimeForView -= 1
      }
    }, 1000)
  }

/**
   * Stop count down view.
   */
  @Log
  stopCountDown() {
    // for freezing view
    if (this.timerId > 0) {
      clearTimeout(this.timerId)
      clearInterval(this.freezingTimeForView)
    }
  }

}