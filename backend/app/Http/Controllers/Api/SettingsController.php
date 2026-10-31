<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\UpdateSettingsRequest;
use App\Http\Resources\SettingsResource;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

final class SettingsController extends Controller
{
    /** GET /api/settings */
    public function show(Request $request): SettingsResource
    {
        return new SettingsResource($request->user());
    }

    /** PUT /api/settings */
    public function update(UpdateSettingsRequest $request): SettingsResource
    {
        $user = $request->user();
        $user->settings = $request->mergedSettings($user->settings ?? []);
        $user->save();

        return new SettingsResource($user->refresh());
    }
}
