<?php

namespace App\Policies;

use App\Models\AiPlan;
use App\Models\User;

final class AiPlanPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, AiPlan $plan): bool
    {
        return $plan->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }
}
