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
import HeadComponent from '../../../../../../../common/component/src/main/ets/default/headComponent';
import {TextComponentWithEndText} from '../../../../../../../common/component/src/main/ets/default/textComponent';
import {DialogButtonLayout} from '../../../../../../../common/component/src/main/ets/default/dialogComponent';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import DateAndTime from '../../../../../../../common/utils/src/main/ets/default/baseUtil/DateAndTimeUtil';
import DateAndTimeModel from '../model/dateAndTimeImpl/DateAndTimeModel'
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import { BaseData } from '../../../../../../../common/utils/src/main/ets/default/bean/BaseData';
import CommonEvent from '@ohos.commonevent';

const MODULE_TAG = ConfigData.TAG + '.dateAndTime -> ';

/**
 * date and time
 */
@Entry
@Component
struct dateAndTime {
  private date: string = '';
  private time: string = '';
  private image: string | Resource = '';
  private dateMark: string = 'date';
  private timeMark: string = 'time';
  private commonEventSubscribeInfo = {events: [CommonEvent.Support.COMMON_EVENT_TIME_CHANGED, CommonEvent.Support.COMMON_EVENT_DATE_CHANGED]};
  private subscriber;
  private headName: string = '';

  @State dateAndTimeList: BaseData[] = [];
  timeDialogController: CustomDialogController = new CustomDialogController({
    builder: TimeDialog24H({ action: this.onAccept }),
    cancel: this.existApp,
    autoCancel: true
  });
  dateDialogController: CustomDialogController = new CustomDialogController({
    builder: DateDialog({ action: this.onAccept }),
    cancel: this.existApp,
    autoCancel: true
  });

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
            HeadComponent({ headName: this.headName, isActive: true })
            Flex({ justifyContent: FlexAlign.SpaceBetween, alignItems:ItemAlign.Center}) {
              Text($r('app.string.timeFormat'))
                .fontSize($r('app.float.font_16'))
                .fontColor($r('app.color.font_color_182431'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
              Toggle({ type: ToggleType.Switch, isOn: this.is24hTimeFormat() })
                .width($r('app.float.switch_toggle_width'))
                .height($r('app.float.switch_toggle_height'))
                .onChange((isOn: boolean) => {
                  if (this.is24hTimeFormat()) {
                    this.setTimeFormatAs12H();
                  } else {
                    this.setTimeFormatAs24H();
                  }
                });
            }
            .height($r('app.float.wh_value_56'))
            .width(ConfigData.WH_100_100)
            .backgroundColor($r("app.color.white_bg_color"))
            .padding({ left: $r('app.float.wh_value_24'), right: $r('app.float.wh_value_24') })
            .margin({ top: $r("app.float.distance_8"), bottom: $r("app.float.wh_value_12")})
            .borderRadius($r('app.float.radius_24'));

            List() {
              ForEach(this.dateAndTimeList, (item) => {
                ListItem() {
                  TextComponentWithEndText({ title: item.settingTitle, endText: item.settingValue, clickEvent: () => {
                    LogUtil.info(MODULE_TAG + 'dialog come in' + JSON.stringify(item))
                    if (item.settingAlias === 'date') {
                      LogUtil.info(MODULE_TAG + 'date dialog come in')
                      this.dateDialogController.open()
                    }
                    if (item.settingAlias === 'time') {
                      LogUtil.info(MODULE_TAG + 'time dialog come in')
                      this.timeDialogController.open()
                    }
                  } });
                }
              }, item => JSON.stringify(item))
            }
            .divider({ strokeWidth: $r('app.float.wh_value_1'), color: $r('app.color.color_E3E3E3_grey'),
              startMargin: $r('app.float.wh_value_15'), endMargin: $r('app.float.wh_value_15') })
            .borderRadius($r("app.float.radius_24"))
            .backgroundColor($r("app.color.white_bg_color"))
            .padding($r('app.float.distance_4'))
            .visibility(this.dateAndTimeList.length > 0 ? Visibility.Visible : Visibility.None)
          }
          .height(ConfigData.WH_100_100)
          .padding({ left: $r('app.float.distance_24'), right: $r('app.float.distance_24') })
          .align(Alignment.Center)
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
  /**
   * Successfully built Dialog
   */
  onAccept() {
    LogUtil.info(MODULE_TAG + 'onAccept');
  }
  /**
   * Cancel Dialog
   */
  existApp() {
    LogUtil.info(MODULE_TAG + 'Cancel dialog!');
  }

  /**
   * modify date and time
   */
  changeValue() {
    this.dateAndTimeList = [
      {
        settingSummary: '',
        settingTitle: $r('app.string.date'),
        settingValue: this.date,
        settingAlias: this.dateMark,
        settingArrow: this.image,
      },
      {
        settingSummary: '',
        settingTitle: $r('app.string.time'),
        settingValue: this.time,
        settingAlias: this.timeMark,
        settingArrow: this.image,
      }
    ]
  }

  aboutToAppear(): void {
    ResourceUtil.getString($r('app.string.dateAndTimeTab')).then(value => {this.headName = value})
    this.image = "/res/image/ic_settings_arrow.svg";
    this.time = DateAndTime.getSystemTime(this.is24hTimeFormat());
    this.date = DateAndTime.getSystemDate();
    this.changeValue();
    this.getNowTime();
    DateAndTimeModel.registerObserver(this.getNowTime.bind(this))
    CommonEvent.createSubscriber(this.commonEventSubscribeInfo)
      .then(subscriber => {
        this.subscriber = subscriber;
        CommonEvent.subscribe(this.subscriber, (error, commonEventData) => {
          this.getNowTime();
          LogUtil.info(`${MODULE_TAG}, CommonEvent Subscribe callback in, error: ${error}, commonEventData: ${commonEventData}`);
        });
      });
  }

  /**
   * get current system time
   */
  private getNowTime(): void {
      LogUtil.info(MODULE_TAG + 'get time come in');
      this.time = DateAndTime.getSystemTime(this.is24hTimeFormat());
      this.date = DateAndTime.getSystemDate();
      LogUtil.info(MODULE_TAG + 'get time end in date=' + this.date);
      LogUtil.info(MODULE_TAG + 'get time end in time=' + this.time);
      this.changeValue();
  }

  aboutToDisappear(): void {
    CommonEvent.unsubscribe(this.subscriber, (error, commonEventData) => {
      LogUtil.info(`${MODULE_TAG}, CommonEvent unSubscribe callback in, error: ${error}, commonEventData: ${commonEventData}`);
    });
    DateAndTimeModel.unregisterObserver();
  }

  onBackPress() {
    Navigator().active(true);
  }

  private setTimeFormatAs24H() {
    DateAndTimeModel.setTimeFormatAs24H();
  }

  private setTimeFormatAs12H() {
    DateAndTimeModel.setTimeFormatAs12H();
  }

  private is24hTimeFormat() : boolean {
    let result = DateAndTimeModel.getTimeFormat();
    if (result === ConfigData.TIME_FORMAT_24) {
      return true;
    }
    return false;
  }
}

/**
 * set time 24h format dialog
 */
@CustomDialog
@Component
struct TimeDialog24H {
  controller: CustomDialogController;
  action: () => void;
  private currentTime;
  private formatTime;

  build() {
    Column() {
      Column() {
        Text($r('app.string.settingTime'))
          .height($r('app.float.wh_value_56'))
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.font_20'))
          .fontWeight(FontWeight.Medium);
        TimePicker({selected: this.currentTime})
          .useMilitaryTime(this.isNeedMilitaryTime())
          .onChange((date: TimePickerResult) => {
            this.currentTime = DateAndTime.concatTime(date.hour, date.minute);
            LogUtil.info(MODULE_TAG + 'onchange currentTime' + this.currentTime);
          })
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_200'))
      }

      DialogButtonLayout({
        firstClickEvent: () => {
          this.controller.close();
          this.action();
        },
        secondClickEvent: () => {
          LogUtil.info(MODULE_TAG + 'button confirm');
          let datetime = new Date();
          let y = datetime.getFullYear();
          let m = datetime.getMonth() + 1;
          let d = datetime.getDate();
          this.formatTime = y + '-' + DateAndTime.fill(m) + '-' + DateAndTime.fill(d)
          + 'T' + this.currentTime + ':' + '00';
          LogUtil.info(MODULE_TAG + 'onchange format time' + this.formatTime);
          let s = (new Date(this.formatTime)).getTime();
          LogUtil.info('onchange time second' + s);
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        }
      })
    }
    .width(ConfigData.WH_100_100)
  }

  private isNeedMilitaryTime() : boolean {
    let result = DateAndTimeModel.getTimeFormat();
    // 24h time format need using military time
    if (result === ConfigData.TIME_FORMAT_24) {
      return true;
    }
    return false;
  }
}

/**
 * set date dialog
 */
@CustomDialog
@Component
struct DateDialog {
  controller: CustomDialogController;
  action: () => void;
  private minDate: Date = new Date('2008-01-01');
  private maxDate: Date = new Date('2037-12-31');
  private selectedDate: Date = this.initValidDate();
  @State date: string = '';
  @State day: string = '';

  build() {
    Column() {
      Column() {
        Row() {
          Text(this.date)
            .fontSize($r('app.float.font_20'))
          Text(this.day)
            .fontSize($r('app.float.font_20'))
        }
        .height($r('app.float.wh_value_56'))

        DatePicker({ start: this.minDate, end: this.maxDate, selected: this.selectedDate })
          .onChange((result: DatePickerResult) => {
            let fmt = result.year + '-' + DateAndTime.fill(result.month + 1) + '-' + DateAndTime.fill(result.day);
            this.selectedDate = new Date(fmt);
            LogUtil.info(MODULE_TAG + 'onchange user select date fmt is : ' + fmt);
            LogUtil.info(MODULE_TAG + 'onchange user select date is :' + this.selectedDate);
            this.date = DateAndTime.concatDate(result.year, result.month + 1, result.day);
            let resource = DateAndTime.convert(result.year, result.month + 1, result.day);
            ResourceUtil.getString(resource).then(value => {
              this.day = value;
              LogUtil.info(MODULE_TAG + 'onchange refresh the show date is : ' + this.date);
              LogUtil.info(MODULE_TAG + 'onchange refresh the show day is : ' + this.day);
            });
        })
          .width(ConfigData.WH_100_100)
          .height($r('app.float.wh_value_200'));
      }

      DialogButtonLayout({
        firstClickEvent: () => {
          this.controller.close();
          this.action();
        },
        secondClickEvent: () => {
          LogUtil.info(MODULE_TAG + 'start set date to : ' + this.selectedDate);
          let sysTime = new Date();
          let fmt = this.selectedDate.getFullYear() + '-' +
          DateAndTime.fill(this.selectedDate.getMonth() + 1) + '-' +
          DateAndTime.fill(this.selectedDate.getDate()) + 'T' +
          DateAndTime.fill(sysTime.getHours()) + ':' +
          DateAndTime.fill(sysTime.getMinutes()) + ':' +
          DateAndTime.fill(sysTime.getSeconds());
          LogUtil.info(MODULE_TAG + 'set date fmt is : ' + fmt);
          let s = (new Date(fmt)).getTime();
          DateAndTimeModel.setTime(s);
          this.controller.close();
          this.action();
        }
      })
    }
    .width(ConfigData.WH_100_100);
  }

  aboutToAppear() {
    let datetime = new Date();
    let y = datetime.getFullYear();
    let m = datetime.getMonth() + 1;
    let d = datetime.getDate();
    this.date = DateAndTime.getSystemDate();
    ResourceUtil.getString(DateAndTime.convert(y, m, d)).then(value => {
      this.day = value;
    });
  }

  private initValidDate() {
    let sysDate = new Date();
    let sysDateTime = sysDate.getTime();
    LogUtil.info(MODULE_TAG + 'init sysDate is :' + sysDateTime);
    if (sysDateTime < this.minDate.getTime()) {
      return this.minDate;
    }
    if (sysDateTime > this.maxDate.getTime()) {
      return this.maxDate;
    }
    return sysDate;
  }
}