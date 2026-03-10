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
        Schema::table('tbl_incident_reports', function (Blueprint $table) {
            $table->string('Is_iselco_pole', 10)->nullable();
            $table->string('Pole_number', 50)->nullable();
            $table->string('Specific_concern', 255)->nullable();
            $table->string('Report_type', 50)->nullable();
            $table->text('Landmarks')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('tbl_incident_reports', function (Blueprint $table) {
            $table->dropColumn([
                'Is_iselco_pole',
                'Pole_number',
                'Specific_concern',
                'Report_type',
                'Landmarks',
            ]);
        });
    }
};
