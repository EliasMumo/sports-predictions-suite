#!/bin/bash

echo "=== Checking and creating missing files ==="

# Shared package
if [ ! -d "packages/predictions_shared" ]; then
    echo "Creating packages/predictions_shared..."
    mkdir -p packages/predictions_shared/lib/src/{constants,models,services,theme}
    
    # List of files to create in shared package
    touch packages/predictions_shared/pubspec.yaml
    touch packages/predictions_shared/lib/predictions_shared.dart
    touch packages/predictions_shared/lib/src/constants/prediction_categories.dart
    touch packages/predictions_shared/lib/src/models/prediction.dart
    touch packages/predictions_shared/lib/src/models/prediction_category.dart
    touch packages/predictions_shared/lib/src/services/prediction_repository.dart
    touch packages/predictions_shared/lib/src/theme/app_colors.dart
    touch packages/predictions_shared/lib/src/theme/app_theme.dart
    echo "✓ Shared package structure created"
else
    echo "✓ packages/predictions_shared already exists"
fi

# End user app
echo "Checking end_user_app..."
mkdir -p apps/end_user_app/lib/features/{controllers,free_tips,navigation,settings,vip_tips,widgets}

[ ! -f "apps/end_user_app/lib/app.dart" ] && touch apps/end_user_app/lib/app.dart && echo "  + app.dart"
[ ! -f "apps/end_user_app/lib/bootstrap.dart" ] && touch apps/end_user_app/lib/bootstrap.dart && echo "  + bootstrap.dart"
[ ! -f "apps/end_user_app/lib/firebase_options.dart" ] && touch apps/end_user_app/lib/firebase_options.dart && echo "  + firebase_options.dart"
[ ! -f "apps/end_user_app/lib/features/controllers/prediction_providers.dart" ] && touch apps/end_user_app/lib/features/controllers/prediction_providers.dart && echo "  + prediction_providers.dart"
[ ! -f "apps/end_user_app/lib/features/free_tips/free_tips_screen.dart" ] && touch apps/end_user_app/lib/features/free_tips/free_tips_screen.dart && echo "  + free_tips_screen.dart"
[ ! -f "apps/end_user_app/lib/features/navigation/root_shell.dart" ] && touch apps/end_user_app/lib/features/navigation/root_shell.dart && echo "  + root_shell.dart"
[ ! -f "apps/end_user_app/lib/features/settings/settings_screen.dart" ] && touch apps/end_user_app/lib/features/settings/settings_screen.dart && echo "  + settings_screen.dart"
[ ! -f "apps/end_user_app/lib/features/vip_tips/vip_tips_screen.dart" ] && touch apps/end_user_app/lib/features/vip_tips/vip_tips_screen.dart && echo "  + vip_tips_screen.dart"
[ ! -f "apps/end_user_app/lib/features/widgets/category_section.dart" ] && touch apps/end_user_app/lib/features/widgets/category_section.dart && echo "  + category_section.dart"
[ ! -f "apps/end_user_app/lib/features/widgets/prediction_card.dart" ] && touch apps/end_user_app/lib/features/widgets/prediction_card.dart && echo "  + prediction_card.dart"

# Admin app
echo "Checking admin_app..."
mkdir -p apps/admin_app/lib/features/{auth,controllers,dashboard}

[ ! -f "apps/admin_app/lib/app.dart" ] && touch apps/admin_app/lib/app.dart && echo "  + app.dart"
[ ! -f "apps/admin_app/lib/bootstrap.dart" ] && touch apps/admin_app/lib/bootstrap.dart && echo "  + bootstrap.dart"
[ ! -f "apps/admin_app/lib/firebase_options.dart" ] && touch apps/admin_app/lib/firebase_options.dart && echo "  + firebase_options.dart"
[ ! -f "apps/admin_app/lib/features/auth/auth_gate.dart" ] && touch apps/admin_app/lib/features/auth/auth_gate.dart && echo "  + auth_gate.dart"
[ ! -f "apps/admin_app/lib/features/auth/auth_providers.dart" ] && touch apps/admin_app/lib/features/auth/auth_providers.dart && echo "  + auth_providers.dart"
[ ! -f "apps/admin_app/lib/features/auth/login_screen.dart" ] && touch apps/admin_app/lib/features/auth/login_screen.dart && echo "  + login_screen.dart"
[ ! -f "apps/admin_app/lib/features/controllers/dashboard_providers.dart" ] && touch apps/admin_app/lib/features/controllers/dashboard_providers.dart && echo "  + dashboard_providers.dart"
[ ! -f "apps/admin_app/lib/features/controllers/prediction_admin_controller.dart" ] && touch apps/admin_app/lib/features/controllers/prediction_admin_controller.dart && echo "  + prediction_admin_controller.dart"
[ ! -f "apps/admin_app/lib/features/dashboard/dashboard_screen.dart" ] && touch apps/admin_app/lib/features/dashboard/dashboard_screen.dart && echo "  + dashboard_screen.dart"
[ ! -f "apps/admin_app/lib/features/dashboard/prediction_form_sheet.dart" ] && touch apps/admin_app/lib/features/dashboard/prediction_form_sheet.dart && echo "  + prediction_form_sheet.dart"
[ ! -f "apps/admin_app/lib/features/dashboard/prediction_list.dart" ] && touch apps/admin_app/lib/features/dashboard/prediction_list.dart && echo "  + prediction_list.dart"

echo ""
echo "=== Done! All missing files created ==="
echo "Next: Copy code content into each file from the earlier messages"
