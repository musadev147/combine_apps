import 'package:rxdart/subjects.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/model/register_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/login_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/login_screen/model/login_model.dart';
import 'package:bd_shope_combined/features/seller/auth/login/presentation/data/rx.dart' as seller_login_rx;
import 'package:bd_shope_combined/features/seller/auth/login/presentation/model/login_model.dart' as seller_login_model;
import 'package:bd_shope_combined/features/buyer/auth/logout/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/otp_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/model/forgot_password_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/model/create_password_model.dart';
import 'package:bd_shope_combined/features/seller/auth/register/presentation/data/rx.dart' as seller_register_rx;
import 'package:bd_shope_combined/features/seller/auth/register/presentation/model/register_model.dart' as seller_register_model;
import 'package:bd_shope_combined/features/seller/auth/otp/presentation/data/rx.dart' as seller_otp_rx;
import 'package:bd_shope_combined/features/seller/auth/forgot_password/presentation/data/rx.dart' as seller_forgot_rx;
import 'package:bd_shope_combined/features/seller/auth/forgot_password/presentation/model/forget_model.dart' as seller_forgot_model;
import 'package:bd_shope_combined/features/seller/auth/create_password/presentation/data/rx.dart' as seller_reset_rx;
import 'package:bd_shope_combined/features/seller/auth/create_password/presentation/model/create_password.dart' as seller_reset_model;
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/model/search_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/data/role_rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/model/register_role.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/data/edit_profile_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/edit_profile_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/data/invoice_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/data/notifications_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/build_invoice_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/serach/presentation/invoice_section/widget/model/notification_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/data/category_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/all_catagory_model.dart' as cat_model;
import 'package:bd_shope_combined/features/buyer/home/home_screen/model/tranding_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/data/company_policy_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/get_company_model.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/data/delete_account_rx.dart';
import 'package:bd_shope_combined/features/buyer/coustomer/model/post_delete_account_model.dart';



GetCategoryRx getCategoryRx = GetCategoryRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<cat_model.Results>>(),
);

GetTrendingTagsRx getTrendingTagsRx = GetTrendingTagsRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<TrandingModel>>(),
);

PostRegisterRx postRegisterRx = PostRegisterRx(
  empty: PostRegisterModel(),
  dataFetcher: BehaviorSubject<PostRegisterModel>(),
);

seller_register_rx.PostRegisterRx sellerPostRegisterRx = seller_register_rx.PostRegisterRx(
  empty: seller_register_model.PostRegisterModel(),
  dataFetcher: BehaviorSubject<seller_register_model.PostRegisterModel>(),
);

PostLoginRx postLoginRx = PostLoginRx(
  empty: PostLoginModel(),
  dataFetcher: BehaviorSubject<PostLoginModel>(),
);

seller_login_rx.PostLoginRx sellerPostLoginRx = seller_login_rx.PostLoginRx(
  empty: seller_login_model.PostLoginModel(),
  dataFetcher: BehaviorSubject<seller_login_model.PostLoginModel>(),
);

PostLogoutRx postLogoutRX = PostLogoutRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
);

PostVerifyOtpRx postVerifyOtpRx = PostVerifyOtpRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
);

seller_otp_rx.PostVerifyOtpRx sellerPostVerifyOtpRx = seller_otp_rx.PostVerifyOtpRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
);

PostForgotPasswordRx postForgotPasswordRx = PostForgotPasswordRx(
  empty: ForgotPasswordModel(),
  dataFetcher: BehaviorSubject<ForgotPasswordModel>(),
);

seller_forgot_rx.PostForgotPasswordRx sellerPostForgotPasswordRx = seller_forgot_rx.PostForgotPasswordRx(
  empty: seller_forgot_model.ForgotPasswordModel(),
  dataFetcher: BehaviorSubject<seller_forgot_model.ForgotPasswordModel>(),
);

PostResetPasswordRx postResetPasswordRx = PostResetPasswordRx(
  empty: PostResetPasswordModel(),
  dataFetcher: BehaviorSubject<PostResetPasswordModel>(),
);

seller_reset_rx.PostResetPasswordRx sellerPostResetPasswordRx = seller_reset_rx.PostResetPasswordRx(
  empty: seller_reset_model.PostResetPasswordModel(),
  dataFetcher: BehaviorSubject<seller_reset_model.PostResetPasswordModel>(),
);

GetSerachTagRx getSerachTagRx = GetSerachTagRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<GetSerachModel>>(),
);

GetRolesRx getRolesRx = GetRolesRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<GetRoleModel>>(),
);



EditProfileRx editProfileRx = EditProfileRx(
  empty: EditProfileResponseModel(),
  dataFetcher: BehaviorSubject<EditProfileResponseModel>(),
);

GetInvoiceRx getInvoiceRx = GetInvoiceRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<GetNotifiInvoiceModel>>(),
);

GetNotificationsRx getNotificationsRx = GetNotificationsRx(
  empty: [],
  dataFetcher: BehaviorSubject<List<NotificationModel>>(),
);

GetCompanyPolicyRx getCompanyPolicyRx = GetCompanyPolicyRx(
  empty: GetCompanyModel(),
  dataFetcher: BehaviorSubject<GetCompanyModel>(),
);

DeleteAccountRx deleteAccountRx = DeleteAccountRx(
  empty: PostAccountModel(),
  dataFetcher: BehaviorSubject<PostAccountModel>(),
);



