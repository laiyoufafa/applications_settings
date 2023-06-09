// @ts-nocheck
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
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import {TitleText} from '../../../../../../../common/component/src/main/ets/default/textComponent';
import {DialogButtonLayout, DialogButtonLayoutWithState} from '../../../../../../../common/component/src/main/ets/default/dialogComponent';
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import SystemAccountController from '../model/usersAndAccounts/systemAccountController';
import SystemAccountModel from '../model/usersAndAccounts/systemAccountModel';
import { MAX_LENGTH } from '../model/usersAndAccounts/systemAccountModel';
import account_osAccount from '@ohos.account.osAccount';
import router from '@system.router';
import InputMethod from '@ohos.inputmethod';


@Entry
@Component
struct MultipleUsers {
  @StorageLink("isShowAddUser") isShowAddUser: boolean = false;
  @StorageLink("isShowAddGuest") isShowAddGuest: boolean = false;
  @StorageLink("systemAccoutList") userList: account_osAccount.OsAccountInfo[] = [];
  @StorageLink("isShowDelete") isShowDelete: boolean = false;
  private addUserDialogController: CustomDialogController = new CustomDialogController({
    builder: AddUserDialog({ controller: this.addUserDialogController, account: {} , confirm: this.onConfirm.bind(this)}),
    autoCancel: true
  });
  private waitDialogController: CustomDialogController = new CustomDialogController({
    builder: WaitDialog({ controller: this.waitDialogController, content: $r("app.string.isCreatingUser")}),
    autoCancel: false
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

          Flex({ direction: FlexDirection.Column, alignItems: Alignment.Center, justifyContent: FlexAlign.SpaceBetween }) {
            Column() {
              // head
              HeadComponent({ headName: $r('app.string.user'), isActive: true });

              // user list
              List() {
                ForEach(this.userList, userItem => {
                  ListItem() {
                    UserItem({ user: userItem })
                  }
                })
              }
              .divider({ strokeWidth: $r('app.float.wh_value_1'), color: $r('app.color.color_E3E3E3_grey'),
                startMargin: $r('app.float.wh_value_20'), endMargin: $r('app.float.wh_value_20') })
              .borderRadius($r("app.float.radius_24"))
              .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
              .padding($r('app.float.distance_4'))
              .margin({top: $r("app.float.distance_16"), bottom: $r("app.float.distance_8")})
              .visibility(this.userList.length > 0 ? Visibility.Visible : Visibility.None)

              // Add user, shown when is administrator
              TitleText({
                title: $r("app.string.addUser"),
                color: $r("app.color.font_color_007DFF"),
                visibility: this.isShowAddUser ? Visibility.Visible : Visibility.None,
                clickEvent: (event => {
                  LogUtil.info("Add user.");
                  this.addUserDialogController.open();
                })
              })

              /**
         * Add guest, shown with conditions:
         * 1. Current user is administrator
         * 2. Guest is not created.
         */
              TitleText({
                title: $r("app.string.addGuest"),
                color: $r("app.color.font_color_007DFF"),
                visibility: this.isShowAddGuest ? Visibility.Visible : Visibility.None,
                clickEvent: ((event) => {
                  AlertDialog.show({
                    message: $r("app.string.askAddGuest"),
                    primaryButton: {
                      value: $r("app.string.cancel"),
                      action: () => {
                        LogUtil.info("Cancel add guest.");
                      }
                    },
                    secondaryButton: {
                      value: $r("app.string.confirm"),
                      action: () => {
                        LogUtil.info("Confirm add guest user.");
                        this.waitDialogController.open();
                        SystemAccountController.createQuest((() => {
                          this.waitDialogController.close();
                        }).bind(this));
                      }
                    },
                    cancel: () => {
                      LogUtil.info("Cancel dialog.")
                    }
                  })
                }).bind(this)
              })
            }
            .height(ConfigData.WH_90_100)
            .alignItems(HorizontalAlign.Start)

            if (this.isShowDelete) {
              Column() {
                Image($r("app.media.ic_delete"))
                  .height($r("app.float.wh_value_40"))
                  .width($r("app.float.wh_value_40"))
                  .margin({ top: $r("app.float.wh_value_20"), bottom: $r("app.float.wh_value_10") })
                Text($r("app.string.deleteButton"))
                  .fontSize($r("app.float.font_20"))
                  .fontColor($r("app.color.font_color_182431"))
                  .margin({ bottom: $r("app.float.wh_value_10") })
              }
              .width(ConfigData.WH_100_100)
              .alignItems(HorizontalAlign.Center)
              .onClick(() => {
                AlertDialog.show({
                  message: $r("app.string.deleteUserWarn"),
                  primaryButton: {
                    value: $r("app.string.cancel"),
                    action: () => {
                      LogUtil.info("Cancel delete user.");
                    }
                  },
                  secondaryButton: {
                    value: $r("app.string.deleteButton"),
                    action: () => {
                      LogUtil.info("Confirm delete user.");
                      SystemAccountController.removeAccount();
                    }
                  }
                });
              })
            }
          }
          .height(ConfigData.WH_100_100)
          .padding({left:$r('app.float.distance_24'), right:$r('app.float.distance_24')})
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

  onConfirm(localName: string) {
    LogUtil.info("Open creating wait dialog");
    this.waitDialogController.open();
    SystemAccountController.createSystemAccount(localName, ((account) => {
      this.waitDialogController.close();
      AlertDialog.show({
        message: $r("app.string.askSwitchUser"),
        primaryButton: {
          value: $r("app.string.cancel"),
          action: () => {
            LogUtil.info("Cancel switch to new user.");
          }
        },
        secondaryButton: {
          value: $r("app.string.switchButton"),
          action: () => {
            LogUtil.info("Confirm switch to new user.");
            SystemAccountController.switchToCreatedAccount();
          }
        },
        cancel: () => {
          LogUtil.info("Cancel dialog.")
        }
      })
    })).bind(this);
  }

  onPageShow() {
    LogUtil.info("Multiple user list about to appear.")
    SystemAccountController.refreshSystemAccountList();
    LogUtil.info("after appear.");
  }

  aboutToDisappear() {
    LogUtil.info('multiple user about to disappear.');
    AppStorage.SetOrCreate("systemAccoutList", []);
  }

  onBackPress() {
    LogUtil.info('multiple user on back press.');
    router.back();
  }

}

@Component
struct UserItem {
  private user: account_osAccount.OsAccountInfo;
  @State isTouched:boolean = false;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: UserItemDialog({ dialogController: this.dialogController, user: this.user }),
    autoCancel: false
  });

  build() {
    Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceBetween }) {
      Row() {
        Image("/res/image/ic_user_portrait.svg")
          .width($r("app.float.wh_value_40"))
          .height($r("app.float.wh_value_40"))
          .margin({ left: $r("app.float.wh_value_12"), right: $r("app.float.wh_value_12") })
        Column() {
            Text(this.user.localName)
              .fontSize($r("app.float.font_16"))
              .fontWeight(FontWeight.Medium)
              .fontColor(Color.Black)
          if (SystemAccountController.isShowIdentity(this.user)) {
            Text(SystemAccountModel.getIdentityFromMap(this.user.type))
              .fontSize($r("app.float.font_14"))
              .fontColor(Color.Black)
          }
        }
        .alignItems(HorizontalAlign.Start)
      }

      Image($r("app.media.ic_settings_arrow"))
        .width($r("app.float.wh_value_12"))
        .height($r("app.float.wh_value_24"))
        .margin({ right: $r("app.float.distance_20") })
    }
    .height($r("app.float.wh_value_72"))
    .onClick(event => {
      LogUtil.info("Click the multiple user item.");
      if (SystemAccountController.isCurrentAdministrator() || SystemAccountController.isCurrentUser(this.user)
        && !SystemAccountController.isGuestAccount(this.user)) {
        this.dialogController.open();
        return;
      }
      if (!SystemAccountController.isCurrentQuest() || !SystemAccountController.isGuestAccount(this.user)) {
        AlertDialog.show({
          message: $r("app.string.switchUser"),
          primaryButton: {
            value: $r("app.string.cancel"),
            action: () => {
              LogUtil.info("Cancel switch to user.");
            }
          },
          secondaryButton: {
            value: $r("app.string.confirm"),
            action: () => {
              SystemAccountController.switchUser(this.user.localId);
            }
          }
        });
      }
    })
    .borderRadius($r('app.float.radius_20'))
    .linearGradient(this.isTouched ? {
       angle: 90,
       direction: GradientDirection.Right,
       colors: [[$r("app.color.DCEAF9"), 0.0], [$r("app.color.FAFAFA"), 1.0]]
       } : {
       angle: 90,
       direction: GradientDirection.Right,
       colors: [[$r("sys.color.ohos_id_color_foreground_contrary"), 1], [$r("sys.color.ohos_id_color_foreground_contrary"), 1]]})
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.isTouched = true;
      }
      if (event.type === TouchType.Up) {
        this.isTouched = false;
      }
    });
  }
}

// Current user item dialog, allow user to set user name and profile image.
@CustomDialog
struct UserItemDialog {
  private user: account_osAccount.OsAccountInfo;
  private dialogController: CustomDialogController;

  build() {
    if (SystemAccountController.isCurrentUser(this.user)) {
      CurrentDialogBuilder({ controller: this.dialogController, user: this.user });
    } else {
      UserDialogBuilder({ controller: this.dialogController, user: this.user });
    }
  }
}

@Component
struct CurrentDialogBuilder {
  private controller: CustomDialogController;
  private user: UserData;
  private tempName: string = "";

  build() {
    Column() {
      Image("/res/image/ic_user_portrait.svg")
        .width($r("app.float.wh_value_40"))
        .height($r("app.float.wh_value_40"))
        .margin({ top: $r("app.float.wh_value_24"), bottom: $r("app.float.wh_value_13") })
        .onClick((event) => {
          LogUtil.info("Click to modify user image.")
          let chooseImageDialog = new  CustomDialogController({
            builder: ChooseImageDialog({ controller: this.controller })
          });
          chooseImageDialog.open();
        })
      Text($r("app.string.addUserImage"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .fontWeight(FontWeight.Medium)
        .margin({ bottom: $r("app.float.wh_value_8") })
      TextInput({ text: this.user.localName })
        .placeholderColor($r("app.color.font_color_182431"))
        .placeholderFont({ size: $r("app.float.font_16"), weight: FontWeight.Normal, style: FontStyle.Normal })
        .width(ConfigData.WH_100_100)
        .margin({bottom: $r("app.float.wh_value_8")})
        .borderRadius($r("app.float.search_input_border_radius"))
        .maxLength(MAX_LENGTH)
        .onChange((value: string) => {
          LogUtil.info("Set current account name, name: " + value);
          this.tempName = value;
        })
        .onSubmit((enterKey) => {
          InputMethod.getInputMethodController().stopInput().then((ret) => {
            LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
          });
        })
      DialogButtonLayout({
        firstClickEvent: () => {
          LogUtil.info("Cancel current user modify dialog.");
          this.controller.close();
        },
        secondClickEvent: () => {
          LogUtil.info("Confirm current user modify dialog.");
          this.controller.close();
          SystemAccountController.setAccountName(this.user.localId, this.tempName);
        }
      })
    }
    .margin({ left: $r("app.float.wh_value_20"), right: $r("app.float.wh_value_20") })
  }
}

// Current user item dialog, allow user to set user name and profile image.
@Component
struct UserDialogBuilder {
  private controller: CustomDialogController;
  private user: account_osAccount.OsAccountInfo;
  private waitController: CustomDialogController = new CustomDialogController({
    builder: WaitDialog({controller: this.waitController, content: $r("app.string.isRemoving")}),
    autoCancel: false
  });

  build() {
    Column() {
      Text(this.user.localName)
        .fontSize($r("app.float.font_20"))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_56"))

      Text($r("app.string.switchUser"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .onClick((event) => {
          this.controller.close();
          SystemAccountController.switchUser(this.user.localId);
        })

      Divider()

      Text($r("app.string.removeUser"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .onClick(() => {
          AlertDialog.show({
            message: $r("app.string.deleteUserWarn"),
            primaryButton: {
              value: $r("app.string.cancel"),
              action: () => {
                LogUtil.info("Cancel delete user.");
              }
            },
            secondaryButton: {
              value: $r("app.string.deleteButton"),
              action: () => {
                LogUtil.info("Confirm delete user.");
                this.waitController.open();
                SystemAccountController.removeAccount(this.user.localId, () => {
                  this.waitController.close();
                });
              }
            },
          });
          this.controller.close();
        })

      Button($r("app.string.cancel"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .backgroundColor(Color.White)
        .margin({ top: $r("app.float.wh_value_16"), bottom: $r("app.float.wh_value_16") })
        .width(ConfigData.WH_100_100)
        .onClick(() => {
          LogUtil.info("Cancel user operation dialog.");
          this.controller.close();
        })
    }
    .alignItems(HorizontalAlign.Start)
    .margin({ left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })
  }
}

@CustomDialog
struct AddUserDialog {
  @State buttonState: boolean = false;
  @State hintText: string = '';
  @State isWarn: boolean = false;
  private controller: CustomDialogController;
  private confirm: (localName: string) => void;
  private account;

  build() {
    Column() {
      Text($r("app.string.addNewUser"))
        .fontSize($r("app.float.font_20"))
        .fontWeight(FontWeight.Medium)
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_56"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
      Image("/res/image/ic_user_portrait.svg")
        .width($r("app.float.wh_value_40"))
        .height($r("app.float.wh_value_40"))
        .margin({ bottom: $r("app.float.wh_value_24") })
      TextInput({
        placeholder: this.hintText
      })
        .placeholderFont({ size: $r("app.float.font_16") })
        .placeholderColor($r("app.color.font_color_182431"))
        .borderRadius($r("app.float.search_input_border_radius"))
        .maxLength(MAX_LENGTH)
        .onChange((value: string) => {
          LogUtil.info("Set the user name: " + value);
          this.account.localName = value;
          this.isWarn = SystemAccountController.isAlreadyCreated(value);
          this.buttonState = value != "" && !this.isWarn;
          LogUtil.info("Set the user name, name: " + this.account.localName);
        })
        .onSubmit((enterKey) => {
          InputMethod.getInputMethodController().stopInput().then((ret) => {
            LogUtil.debug( `${ConfigData.TAG}, enterType: ${enterKey}, stopInput: ${ret}`);
          });
        })
      if (this.isWarn) {
        Text($r("app.string.userCreatedWarn"))
          .fontSize($r("app.float.font_14"))
          .fontColor(Color.Red)
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Start)
          .margin({ top: $r("app.float.wh_value_8"), bottom: $r("app.float.wh_value_8") })
      } else {
        Text($r("app.string.addUserDescription"))
          .fontSize($r("app.float.font_16"))
          .fontColor($r("app.color.font_color_182431"))
          .width(ConfigData.WH_100_100)
          .textAlign(TextAlign.Start)
          .margin({ top: $r("app.float.wh_value_8"), bottom: $r("app.float.wh_value_8") })
      }
      DialogButtonLayoutWithState({
        firstClickEvent: () => {
          LogUtil.info("Cancel add new user.");
          this.controller.close();
        },
        secondClickEvent: () => {
          LogUtil.info("Confirm Add new user.");
          this.controller.close();
          this.confirm(this.account.localName);
        },
        secondButtonState: this.buttonState
      })
    }
    .margin({ left: $r("app.float.wh_value_24"), right: $r("app.float.wh_value_24") })
  }

  aboutToAppear() {
    ResourceUtil.getString($r("app.string.nickname")).then(value => this.hintText = value);
  }
}

@CustomDialog
struct ChooseImageDialog {
  private controller: CustomDialogController;

  build() {
    Column() {
      Text($r("app.string.takePhoto"))
        .fontSize($r("app.float.font_24"))
        .fontColor($r("app.color.font_color_182431"))
        .onClick(() => {
          router.push({ uri: "" });
        })
      Text($r("app.string.chooseFromShop"))
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .onClick(() => {
          router.push({ uri: "" })
        })
    }
  }
}

@CustomDialog
struct WaitDialog{
  private controller: CustomDialogController;
  private content: string | Resource;

  build() {
    Row() {
      Text(this.content)
        .fontSize($r("app.float.font_16"))
        .fontColor($r("app.color.font_color_182431"))
        .height($r("app.float.wh_value_48"))
        .width(ConfigData.WH_100_100)
        .textAlign(TextAlign.Start)
        .fontWeight(FontWeight.Medium)
        .padding({
          top: $r("app.float.distance_8"),
          bottom: $r("app.float.distance_8")
        })
    }
    .alignItems(VerticalAlign.Center)
    .height($r("app.float.wh_value_80"))
    .padding({
      left: $r("app.float.distance_24"),
      right: $r("app.float.distance_24")
    })
  }
}
