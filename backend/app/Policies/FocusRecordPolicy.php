<?php

namespace App\Policies;

use App\Models\FocusRecord;
use App\Models\User;

final class FocusRecordPolicy
{
    public function viewAny(User $user): bool
    {
        return true;
    }

    public function view(User $user, FocusRecord $record): bool
    {
        return $record->user_id === $user->id;
    }

    public function create(User $user): bool
    {
        return true;
    }

    public function delete(User $user, FocusRecord $record): bool
    {
        return $record->user_id === $user->id;
    }
}
