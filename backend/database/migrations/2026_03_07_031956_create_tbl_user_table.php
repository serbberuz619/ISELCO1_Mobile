<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tbl_user', function (Blueprint $table) {
            $table->id('User_id');
            $table->string('Fullname')->nullable();
            $table->string('Account_number')->nullable();
            $table->string('Town')->nullable();
            $table->string('Barangay')->nullable();
            $table->string('Sitio')->nullable();
            $table->string('Phone_number')->nullable();
            $table->string('Email')->nullable();
            $table->string('Google_id')->nullable();
            $table->string('Password')->nullable();
            $table->enum('Verification_status', ['PENDING', 'APPROVED', 'REJECTED'])->default('PENDING');
            $table->enum('Status', ['ACTIVE', 'INACTIVE', 'SUSPENDED'])->default('INACTIVE');
            $table->enum('Role', ['USER', 'ADMIN', 'SUPERADMIN'])->default('USER');
            $table->string('Upload_path')->nullable();
            $table->boolean('Biometric_enable')->default(true);
            $table->string('Remember_token')->nullable();
            $table->string('Verified_by')->nullable();
            $table->timestamp('Verified_at')->nullable();
            $table->timestamp('Created_at')->useCurrent();
            $table->timestamp('Updated_at')->useCurrent()->useCurrentOnUpdate();
            $table->timestamp('Deleted_at')->nullable();
        });

          Schema::create('password_reset_tokens', function (Blueprint $table) {
            $table->string('email')->primary();
            $table->string('token');
            $table->timestamp('created_at')->nullable();
        });

        Schema::create('sessions', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->index();
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->longText('payload');
            $table->integer('last_activity')->index();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tbl_user');
            Schema::dropIfExists('password_reset_tokens');
        Schema::dropIfExists('sessions');
    }
};
