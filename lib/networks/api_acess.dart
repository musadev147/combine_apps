import 'package:rxdart/subjects.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/register_screen/model/register_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/login_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/login_screen/model/login_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/logout/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/otp_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/forgot_password_screen/model/forgot_password_model.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/data/rx.dart';
import 'package:bd_shope_combined/features/buyer/auth/create_password_screen/model/create_password_model.dart';
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

PostLoginRx postLoginRx = PostLoginRx(
  empty: PostLoginModel(),
  dataFetcher: BehaviorSubject<PostLoginModel>(),
);

PostLogoutRx postLogoutRX = PostLogoutRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
);

PostVerifyOtpRx postVerifyOtpRx = PostVerifyOtpRx(
  empty: {},
  dataFetcher: BehaviorSubject<Map<String, dynamic>>(),
);

PostForgotPasswordRx postForgotPasswordRx = PostForgotPasswordRx(
  empty: ForgotPasswordModel(),
  dataFetcher: BehaviorSubject<ForgotPasswordModel>(),
);

PostResetPasswordRx postResetPasswordRx = PostResetPasswordRx(
  empty: PostResetPasswordModel(),
  dataFetcher: BehaviorSubject<PostResetPasswordModel>(),
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



